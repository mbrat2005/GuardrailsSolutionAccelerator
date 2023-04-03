//Scope
targetScope = 'resourceGroup'
//Parameters and variables
param AllowedLocationPolicyId string = 'e56962a6-4747-49cd-b67b-bf8b01975c4c'
param automationAccountName string = 'guardrails-AC'
param CBSSubscriptionName string 
param ModuleBaseURL string
param DepartmentNumber string
param DepartmentName string
param deployKV bool = true
param deployLAW bool = true
param DeployTelemetry bool = true
param HealthLAWResourceId string
param lighthouseTargetManagementGroupID string
param Locale string = 'EN'
param location string = 'canadacentral'
param logAnalyticsWorkspaceName string = 'guardrails-LAW'
param newDeployment bool = true
param PBMMPolicyID string = '4c4a5f27-de81-430b-b4e5-9cbd50595a87'
param releaseDate string 
param releaseVersion string
param SecurityLAWResourceId string
param SSCReadOnlyServicePrincipalNameAPPID string
param subscriptionId string
param TenantDomainUPN string
param updateCoreResources bool = false
param updatePSModules bool = false
param updateWorkbook bool = false

var GRDocsBaseUrl='https://github.com/Azure/GuardrailsSolutionAccelerator/docs/'
var rg=resourceGroup().name

//Resources:

module telemetry './nested_telemetry.bicep' = if (DeployTelemetry) {
  name: 'pid-9c273620-d12d-4647-878a-8356201c7fe8'
  params: {}
}
module aa 'modules/automationaccount.bicep' = if (newDeployment || updatePSModules || updateCoreResources) {
  name: 'guardrails-automationaccount'
  params: {
    AllowedLocationPolicyId: AllowedLocationPolicyId
    automationAccountName: automationAccountName
    CBSSubscriptionName: CBSSubscriptionName
    ModuleBaseURL: ModuleBaseURL
    DepartmentNumber: DepartmentNumber
    DepartmentName: DepartmentName
    guardrailsLogAnalyticscustomerId: LAW.outputs.logAnalyticsWorkspaceId
    HealthLAWResourceId: HealthLAWResourceId
    lighthouseTargetManagementGroupID: lighthouseTargetManagementGroupID
    Locale: Locale
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    newDeployment: newDeployment
    PBMMPolicyID: PBMMPolicyID
    releaseDate: releaseDate
    releaseVersion: releaseVersion
    SecurityLAWResourceId: SecurityLAWResourceId
    SSCReadOnlyServicePrincipalNameAPPID:SSCReadOnlyServicePrincipalNameAPPID
    TenantDomainUPN: TenantDomainUPN
    updatePSModules: updatePSModules
    updateCoreResources: updateCoreResources
  }
  dependsOn: [
    LAW
  ]
}

module LAW 'modules/loganalyticsworkspace.bicep' = if ((deployLAW && newDeployment) || updateWorkbook || updateCoreResources) {
  name: 'guardrails-loganalytics'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    location: location
    releaseVersion: releaseVersion
    releaseDate: releaseDate
    rg: rg
    deployLAW: deployLAW
    subscriptionId: subscription().subscriptionId
    GRDocsBaseUrl: GRDocsBaseUrl
    newDeployment: newDeployment
    updateWorkbook: updateWorkbook
  }
}

module alertNewVersion 'modules/alert.bicep' = {
  name: 'guardrails-alertNewVersion'
  dependsOn: [
    aa
    LAW
  ]
  params: {
    alertRuleDescription: 'Alerts when a new version of the Guardrails Solution Accelerator is available'
    alertRuleName: 'GuardrailsNewVersion'
    alertRuleDisplayName: 'Guardrails New Version Available.'
    alertRuleSeverity: 3
    location: location
    query: 'GR_VersionInfo_CL | summarize total=count() by UpdateAvailable=iff(CurrentVersion_s != AvailableVersion_s, "Yes",\'No\') | where UpdateAvailable == \'Yes\''
    scope: LAW.outputs.logAnalyticsResourceId
    autoMitigate: true
    evaluationFrequency: 'PT6H'
    windowSize: 'PT6H'
  }
}
output guardrailsAutomationAccountMSI string = newDeployment ? aa.outputs.guardrailsAutomationAccountMSI : ''
