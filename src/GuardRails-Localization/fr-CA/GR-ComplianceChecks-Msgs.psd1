ConvertFrom-StringData @'

# French strings

CtrName1 = GUARDRAIL 1: PROTÉGER LE COMPTE RACINE / ADMINISTRATEURS GLOBAUX
CtrName2 = GUARDRAIL 2: GESTION DES PRIVILÈGES ADMINISTRATIFS
CtrName3 = GUARDRAIL 3: ACCÈS À LA CONSOLE CLOUD
CtrName4 = GUARDRAIL 4: COMPTES DE SURVEILLANCE D'ENTREPRISE
CtrName5 = GUARDRAIL 5: EMPLACEMENT DES DONNÉES
CtrName6 = GUARDRAIL 6: PROTECTION DES DONNÉES AU REPOS
CtrName7 = GUARDRAIL 7: PROTECTION DES DONNÉES EN TRANSIT
CtrName8 = GUARDRAIL 8: SEGMENTATION ET SÉPARATION DU RÉSEAU
CtrName9 = GUARDRAIL 9: SERVICES DE SÉCURITÉ RÉSEAU
CtrName10 = GUARDRAIL 10: SERVICES DE CYBER DÉFENSE
CtrName11 = GUARDRAIL 11: ENREGISTREMENT ET SURVEILLANCE
CtrName12 = GUARDRAIL 12: CONFIGURATION DES MARKETPLACES

# Guardrail 1
adLicense = Type de licence AD
mfaEnforcement = Application MFA
mfaEnabledFor =  L'authentication MFA ne devrait pas être activée pour le compte brise-glace: {0} 
mfaDisabledFor =  L'authentication MFA n'est pas activée pour {0} 
m365Assignment = Affectation Microsoft 365 E5
bgProcedure = Procédure de compte Brise Glace
bgCreation = Création de compte Brise Glace
bgAccountResponsibility = La responsabilité des comptes brise-glace doit incomber à une personne non technique, de niveau directeur ou supérieur
bgAccountOwnerContact = Coordonnées des titulaires de compte Brise Glace
bgAccountsCompliance = Statut de conformité du premier compte brise-glace = {0}, Statut de conformité du deuxième compte brise-glace = {1}
bgAuthenticationMeth =  Méthodes d'authentification 
firstBgAccount = Premier compte brise-glace
secondBgAccount = Deuxième compte brise-glace
bgNoValidLicenseAssigned = Aucune licence AAD P2 assignée au 
bgValidLicenseAssigned =  a une licence AAD P2 valide
bgAccountHasManager = Le compte BG {0} a un responsable
bgAccountNoManager =  Le compte BG {0} n'a pas de gestionnaire 
bgBothHaveManager =  Les deux comptes brise-glace ont un gestionnaire

# GuardRail #2
removeDeletedAccount = Supprimez définitivement les comptes supprimés
removeDeprecatedAccount = Supprimez les comptes obsolètes
removeGuestAccounts = Supprimez les comptes invités.
accountNotDeleted = Ce compte d'utilisateur a été supprimé mais n'a pas encore été SUPPRIMÉ DÉFINITIVEMENT d'Azure Active Directory
guestMustbeRemoved = Ce comptes invité ne devraient pas avoir de rôles dans les abonnements Azure
removeGuestAccountsComment = Supprimez les comptes invités d'Azure AD ou supprimez leurs permissions dans les abonnements Azure.
noGuestAccounts = Il n'y a aucun compte invité dans votre tenant
guestAccountsNoPermission = Il y a des comptes invités dans le tenant mais ils n'ont pas de permissions dans les abonnements Azure.
ADDeletedUser = Utilisateur AD Supprimé
ADDisabledUsers = Utilisateur AD désactivé
noncompliantUsers = Les utilisateurs suivants sont désactivés et ne sont pas synchronisés avec AD: - 
noncompliantComment = Nombre d'utilisateurs non-conformes {0}. 
compliantComment = Aucun utilisateur non synchronisé ou désactivé trouvé
mitigationCommands = Vérifiez si les utilisateurs trouvés sont obsolètes. 
apiError = Erreur API
apiErrorMitigation = Vérifiez l'existence des utilisateurs ou les permissions de l'application.
AADLicenseTypeFound = Type de licence AAD trouvé 
AADLicenseTypeNotFound = Type de licence AAD non trouvé

# GuardRail #3
noCompliantPoliciesfound=Aucune stratégie conforme n'a été trouvée. Les politiques doivent avoir un emplacement unique et cet emplacement doit être réservé au Canada.
allPoliciesAreCompliant=Toutes les politiques sont conformes.
noLocationsCompliant=Aucun endroit n'a seulement le Canada en eux.
consoleAccessConditionalPolicy = Stratégie d'accès conditionnel pour l'accès à la console.

# GuardRail #4
monitorAccount = Surveiller la création de compte
checkUserExistsError = L'appel API a retourné l'erreur {0}. Veuillez vérifier si l'utilisateur existe.
checkUserExists = Veuillez vérifier si l'utilisateur existe.

# GuardRail #5-6
pbmmCompliance = Conformité PBMMPolicy
policyNotAssigned = La politique ou l'initiative n'est pas affectée au {0}
excludeFromScope = {0} est exclu de la portée de l'affectation
isCompliant = Conforme
policyNotAssignedRootMG = La politique ou l'initiative n'est pas affectée aux groupes de gestion racine
rootMGExcluded = Ce groupe de gestion racine est exclu de la portée de l'affectation
pbmmNotApplied = L'initiative PBMM n'est pas appliquée.
grexemptionFound = excemption pour {0} {1} trouvée
subscription  = abonnement
managementGroup = Groupes de gestion
notAllowedLocation =  L'emplacement est en dehors des emplacements autorisés. 
allowLocationPolicy = Politique de localisation autorisée
dataAtRest = PROTECTION DES DONNÉES-AU-REPOS
dataInTransit = PROTECTION DES DONNÉES-EN-TRANSIT

# GuardRail #8
noNSG=Aucun NSG n'est présent.
subnetCompliant = Le sous-réseau est conforme.
nsgConfigDenyAll = NSG est présent mais n'est pas correctement configuré (dernière règle de refus manquante).
nsgCustomRule = NSG est présent mais n'est pas correctement configuré (règles personnalisées manquantes).
networkSegmentation = Segmentation
networkSeparation = Séparation
routeNVA = Route présente mais non dirigée vers une appliance virtuelle.
routeNVAMitigation = Mettre à jour la route pour pointer vers une appliance virtuelle
noUDR = Aucune route définie par l'utilisateur configurée.
noUDRMitigation = Veuillez appliquer une route personnalisée à ce sous-réseau, pointant vers une appliance virtuelle.
subnetExcluded = Sous-réseau exclu (nom manuel ou réservé).
networkDiagram = Diagramme d'architecture réseau 
noSubnets = Aucun sous-réseau n'est présent.

# GuardRail # 9
vnetDDosConfig = Configuration DDos VNet
ddosEnabled = Protection DDos activée. 
ddosNotEnabled = Protection DDos non activée.
noVNets = Aucun VNet n'est présent.

# GuardRail #10
cbsSubDoesntExist = L'abonnement CBS n'existe pas
cbcSensorsdontExist = Les capteurs CBC attendus n'existent pas
cbssMitigation = Vérifiez l'abonnement fourni: {0} ou vérifiez l'existence de la solution CBS dans l'abonnement fourni.
cbssCompliant = Ressources trouvées dans ces abonnements: 

# GuardRail #11
securityMonitoring = Surveillance de la sécurité
HealthMonitoring = Surveillance Santé
defenderMonitoring =Surveillance Defender
securityLAWNotFound = L'espace de travail Log Analytics spécifié pour la surveillance de la sécurité est introuvable.
lawRetention730Days = La rétention n'est pas définie sur 730 jours.
lawNoActivityLogs = WorkSpace n'est pas configuré pour ingérer les journaux d'activité.
lawSolutionNotFound = Les solutions requises ne sont pas présentes dans l'espace de travail Log Analytics.
lawNoAutoAcct = Aucun compte d'automatisation lié n'a été trouvé.
lawNoTenantDiag = Les paramètres de diagnostic des locataires ne pointent pas vers l'espace de travail d'analyse des journaux fourni.
lawMissingLogTypes = L'espace de travail est défini dans la configuration du locataire, mais tous les types de journaux requis ne sont pas activés (audit et connexion).
healthLAWNotFound = L'espace de travail Log Analytics spécifié pour la surveillance de la santé est introuvable.
lawRetention90Days = La rétention n'est pas définie sur au moins 90 jours.
lawHealthNoSolutionFound = Les solutions requises ne sont pas présentes dans l'espace de travail Health Log Analytics.
createLAW = Veuillez créer un espace de travail d'analyse de journaux conformément aux directives.
connectAutoAcct = Veuillez connecter un compte d'automatisation à l'espace de travail fourni.
setRetention60Days = Définir la rétention de l'espace de travail sur au moins 90 jours pour l'espace de travail: 
setRetention730Days = Définir la rétention de l'espace de travail à 730 jours pour l'espace de travail: 
addActivityLogs = Veuillez ajouter la solution Activity Logs à l'espace de travail: 
addUpdatesAndAntiMalware = Veuillez ajouter à la fois la solution Mises à jour et Anti-Malware à l'espace de travail: 
configTenantDiag = Veuillez configurer les diagnostics de locataire pour qu'ils pointent vers l'espace de travail fourni: 
addAuditAndSignInsLogs = Veuillez activer les journaux d'audit et SignInLogs dans les paramètres de Tenant Dianostics.
logsAndMonitoringCompliantForSecurity = Les journaux et la surveillance sont conformes pour la sécurité.
logsAndMonitoringCompliantForHealth = Les journaux et la surveillance sont conformes pour la santé.
logsAndMonitoringCompliantForDefender = Les journaux et la surveillance sont conformes pour Defender.
createHealthLAW = Veuillez créer un espace de travail pour la surveillance de la santé conformément aux directives de Guardrails.
enableAgentHealthSolution = Veuillez activer la solution d'évaluation de l'état de santé de l'agent dans l'espace de travail.
lawEnvironmentCompliant = L'environnement est conforme.
noSecurityContactInfo = L'abonnement {0} manque d'informations de contact.
setSecurityContact = Veuillez définir un contact de sécurité pour Defender for Cloud dans l'abonnement. {0}
notAllDfCStandard = Toutes les options de plan de tarification ne sont pas définies sur Standard pour l'abonnement {0}
setDfCToStandard = Veuillez définir les forfaits Defender pour le cloud sur Standard. ({0})

# GuardRail #12
mktPlaceCreation = Création Place de marché
mktPlaceCreated = Le marché privé a été créé.
mktPlaceNotCreated = Le marché privé n'a pas été créé.
enableMktPlace = Activer Azure Private MarketPlace selon: https://docs.microsoft.com/en-us/marketplace/create-manage-private-azure-marketplace-new

# GR-Common
procedureFileFound = Fichier {0} trouvé.
procedureFileNotFound = Impossible de trouver le document pour {0}, veuillez créer et télécharger un fichier avec le nom {1} dans le conteneur {2} du compte de stockage {3} pour confirmer que vous avez terminé l'élément dans le contrôle.

'@
# SIG # Begin signature block
# MIInzQYJKoZIhvcNAQcCoIInvjCCJ7oCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBATzQWjntNZRhd
# pfUGSVbkhenNWRuFlGXBpLRy2hvmRaCCDYEwggX/MIID56ADAgECAhMzAAACzI61
# lqa90clOAAAAAALMMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjIwNTEyMjA0NjAxWhcNMjMwNTExMjA0NjAxWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCiTbHs68bADvNud97NzcdP0zh0mRr4VpDv68KobjQFybVAuVgiINf9aG2zQtWK
# No6+2X2Ix65KGcBXuZyEi0oBUAAGnIe5O5q/Y0Ij0WwDyMWaVad2Te4r1Eic3HWH
# UfiiNjF0ETHKg3qa7DCyUqwsR9q5SaXuHlYCwM+m59Nl3jKnYnKLLfzhl13wImV9
# DF8N76ANkRyK6BYoc9I6hHF2MCTQYWbQ4fXgzKhgzj4zeabWgfu+ZJCiFLkogvc0
# RVb0x3DtyxMbl/3e45Eu+sn/x6EVwbJZVvtQYcmdGF1yAYht+JnNmWwAxL8MgHMz
# xEcoY1Q1JtstiY3+u3ulGMvhAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUiLhHjTKWzIqVIp+sM2rOHH11rfQw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDcwNTI5MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAeA8D
# sOAHS53MTIHYu8bbXrO6yQtRD6JfyMWeXaLu3Nc8PDnFc1efYq/F3MGx/aiwNbcs
# J2MU7BKNWTP5JQVBA2GNIeR3mScXqnOsv1XqXPvZeISDVWLaBQzceItdIwgo6B13
# vxlkkSYMvB0Dr3Yw7/W9U4Wk5K/RDOnIGvmKqKi3AwyxlV1mpefy729FKaWT7edB
# d3I4+hldMY8sdfDPjWRtJzjMjXZs41OUOwtHccPazjjC7KndzvZHx/0VWL8n0NT/
# 404vftnXKifMZkS4p2sB3oK+6kCcsyWsgS/3eYGw1Fe4MOnin1RhgrW1rHPODJTG
# AUOmW4wc3Q6KKr2zve7sMDZe9tfylonPwhk971rX8qGw6LkrGFv31IJeJSe/aUbG
# dUDPkbrABbVvPElgoj5eP3REqx5jdfkQw7tOdWkhn0jDUh2uQen9Atj3RkJyHuR0
# GUsJVMWFJdkIO/gFwzoOGlHNsmxvpANV86/1qgb1oZXdrURpzJp53MsDaBY/pxOc
# J0Cvg6uWs3kQWgKk5aBzvsX95BzdItHTpVMtVPW4q41XEvbFmUP1n6oL5rdNdrTM
# j/HXMRk1KCksax1Vxo3qv+13cCsZAaQNaIAvt5LvkshZkDZIP//0Hnq7NnWeYR3z
# 4oFiw9N2n3bb9baQWuWPswG0Dq9YT9kb+Cs4qIIwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZojCCGZ4CAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAsyOtZamvdHJTgAAAAACzDAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg6juWHIlD
# 2zHeGjraNWS7Aa7iHC4sE34wVBRhbLD+brEwQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQBYuwIVeOAMMtEUr1wsBNW+EqPqQMRvzdULXnlvSHHf
# isVxRVhwfwW4Z7pO+lMdWA0kuJ67aWIJM/GTIJg7cFPQ4QRVMCkAfiFHdSh7ObPA
# 7HdDBWCDErszBs5uUwXlz3AAKwK3wgm1wCO3chiPNF+cTYKAHm9uKdE0ILgLMci8
# 0+NFALTSyfAZVEtWcfWBpwMBqn9qKEHAiV4U7NproTGyct4OvDc6uaqD6vfY1DsZ
# qkjYLQT6PXDz4oE5Dq+BkdqqpHo4dmpj0ovTuqOtNBaEPIJ7V4J04JUjuCnf6USd
# 4e6ZdKVy7KJ+XhU40nfHU6TT8AwXh5kMQMLy/GHVKE1JoYIXLDCCFygGCisGAQQB
# gjcDAwExghcYMIIXFAYJKoZIhvcNAQcCoIIXBTCCFwECAQMxDzANBglghkgBZQME
# AgEFADCCAVkGCyqGSIb3DQEJEAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIIvi3bsfgXArZNO+u5+FE5Tg4yPtcsouyfS7uwIw
# qIltAgZjx91C8ZIYEzIwMjMwMjAyMTUwMTE5LjQ2MVowBIACAfSggdikgdUwgdIx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
# Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhh
# bGVzIFRTUyBFU046RkM0MS00QkQ0LUQyMjAxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2WgghF7MIIHJzCCBQ+gAwIBAgITMwAAAbn2AA1lVE+8
# AwABAAABuTANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMDAeFw0yMjA5MjAyMDIyMTdaFw0yMzEyMTQyMDIyMTdaMIHSMQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQg
# SXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
# RVNOOkZDNDEtNEJENC1EMjIwMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA40k+yWH1
# FsfJAQJtQgg3EwXm5CTI3TtUhKEhNe5sulacA2AEIu8JwmXuj/Ycc5GexFyZIg0n
# +pyUCYsis6OdietuhwCeLGIwRcL5rWxnzirFha0RVjtVjDQsJzNj7zpT/yyGDGqx
# p7MqlauI85ylXVKHxKw7F/fTI7uO+V38gEDdPqUczalP8dGNaT+v27LHRDhq3HSa
# QtVhL3Lnn+hOUosTTSHv3ZL6Zpp0B3LdWBPB6LCgQ5cPvznC/eH5/Af/BNC0L2WE
# DGEw7in44/3zzxbGRuXoGpFZe53nhFPOqnZWv7J6fVDUDq6bIwHterSychgbkHUB
# xzhSAmU9D9mIySqDFA0UJZC/PQb2guBI8PwrLQCRfbY9wM5ug+41PhFx5Y9fRRVl
# Sxf0hSCztAXjUeJBLAR444cbKt9B2ZKyUBOtuYf/XwzlCuxMzkkg2Ny30bjbGo3x
# UX1nxY6IYyM1u+WlwSabKxiXlDKGsQOgWdBNTtsWsPclfR8h+7WxstZ4GpfBunhn
# zIAJO2mErZVvM6+Li9zREKZE3O9hBDY+Nns1pNcTga7e+CAAn6u3NRMB8mi285Kp
# wyA3AtlrVj4RP+VvRXKOtjAW4e2DRBbJCM/nfnQtOm/TzqnJVSHgDfD86zmFMYVm
# AV7lsLIyeljT0zTI90dpD/nqhhSxIhzIrJUCAwEAAaOCAUkwggFFMB0GA1UdDgQW
# BBS3sDhx21hDmgmMTVmqtKienjVEUjAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJl
# pxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAx
# MCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3Rh
# bXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQM
# MAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAgEA
# zdxns0VQdEywsrOOXusk8iS/ugn6z2SS63SFmJ/1ZK3rRLNgZQunXOZ0+pz7Dx4d
# OSGpfQYoKnZNOpLMFcGHAc6bz6nqFTE2UN7AYxlSiz3nZpNduUBPc4oGd9UEtDJR
# q+tKO4kZkBbfRw1jeuNUNSUYP5XKBAfJJoNq+IlBsrr/p9C9RQWioiTeV0Z+OcC2
# d5uxWWqHpZZqZVzkBl2lZHWNLM3+jEpipzUEbhLHGU+1x+sB0HP9xThvFVeoAB/T
# Y1mxy8k2lGc4At/mRWjYe6klcKyT1PM/k81baxNLdObCEhCY/GvQTRSo6iNSsElQ
# 6FshMDFydJr8gyW4vUddG0tBkj7GzZ5G2485SwpRbvX/Vh6qxgIscu+7zZx4NVBC
# 8/sYcQSSnaQSOKh9uNgSsGjaIIRrHF5fhn0e8CADgyxCRufp7gQVB/Xew/4qfdeA
# wi8luosl4VxCNr5JR45e7lx+TF7QbNM2iN3IjDNoeWE5+VVFk2vF57cH7JnB3ckc
# Mi+/vW5Ij9IjPO31xTYbIdBWrEFKtG0pbpbxXDvOlW+hWwi/eWPGD7s2IZKVdfWz
# vNsE0MxSP06fM6Ucr/eas5TxgS5F/pHBqRblQJ4ZqbLkyIq7Zi7IqIYEK/g4aE+y
# 017sAuQQ6HwFfXa3ie25i76DD0vrII9jSNZhpC3MA/0wggdxMIIFWaADAgECAhMz
# AAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9v
# dCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0yMTA5MzAxODIyMjVaFw0z
# MDA5MzAxODMyMjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMIICIjAN
# BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA5OGmTOe0ciELeaLL1yR5vQ7VgtP9
# 7pwHB9KpbE51yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64NmeFRiMM
# tY0Tz3cywBAY6GB9alKDRLemjkZrBxTzxXb1hlDcwUTIcVxRMTegCjhuje3XD9gm
# U3w5YQJ6xKr9cmmvHaus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl3GoPz130
# /o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHINSi947SHJMPgyY9+tVSP
# 3PoFVZhtaDuaRr3tpK56KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I5JasAUq7
# vnGpF1tnYN74kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+/NmeRd+2ci/bfV+A
# utuqfjbsNkz2K26oElHovwUDo9Fzpk03dJQcNIIP8BDyt0cY7afomXw/TNuvXsLz
# 1dhzPUNOwTM5TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLiMxhy16cg8ML6
# EgrXY28MyTZki1ugpoMhXV8wdJGUlNi5UPkLiWHzNgY1GIRH29wb0f2y1BzFa/Zc
# UlFdEtsluq9QBXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6HXtqPnhZy
# acaue7e3PmriLq0CAwEAAaOCAd0wggHZMBIGCSsGAQQBgjcVAQQFAgMBAAEwIwYJ
# KwYBBAGCNxUCBBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQWBBSfpxVd
# AF5iXYP05dJlpxtTNRnpcjBcBgNVHSAEVTBTMFEGDCsGAQQBgjdMg30BATBBMD8G
# CCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3Mv
# UmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgwGQYJKwYBBAGCNxQC
# BAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYD
# VR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZF
# aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9v
# Q2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcw
# AoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJB
# dXRfMjAxMC0wNi0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1VffwqreEsH2cB
# MSRb4Z5yS/ypb+pcFLY+TkdkeLEGk5c9MTO1OdfCcTY/2mRsfNB1OW27DzHkwo/7
# bNGhlBgi7ulmZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pvvinLbtg/
# SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OOPcbzaN9l9qRWqveVtihVJ9AkvUCgvxm2
# EhIRXT0n4ECWOKz3+SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWKNsIdw2Fz
# Lixre24/LAl4FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7hvoyGtmW9I/2kQH2zsZ0
# /fZMcm8Qq3UwxTSwethQ/gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+c23Kjgm9
# swFXSVRk2XPXfx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFUa2pFEUep8beuyOiJ
# Xk+d0tBMdrVXVAmxaQFEfnyhYWxz/gq77EFmPWn9y8FBSX5+k77L+DvktxW/tM4+
# pTFRhLy/AsGConsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1ZyvgDbjmjJnW
# 4SLq8CdCPSWU5nR0W2rRnj7tfqAxM328y+l7vzhwRNGQ8cirOoo6CGJ/2XBjU02N
# 7oJtpQUQwXEGahC0HVUzWLOhcGbyoYIC1zCCAkACAQEwggEAoYHYpIHVMIHSMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNy
# b3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxl
# cyBUU1MgRVNOOkZDNDEtNEJENC1EMjIwMSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDHYh4YeGTnwxCTPNJaScZw
# uN+BOqCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqG
# SIb3DQEBBQUAAgUA54YhtjAiGA8yMDIzMDIwMjE5NDkxMFoYDzIwMjMwMjAzMTk0
# OTEwWjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDnhiG2AgEAMAoCAQACAhLBAgH/
# MAcCAQACAhFPMAoCBQDnh3M2AgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQB
# hFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEFBQADgYEA
# Zo58Eyg3vwb0FTMv1vqporFceMk9Fn8R/r9HE+EI31lEiI2mpDDTdcaZ0durLYn4
# dfXNvmTxgim9oBJ5ZF1tyzpLlQd/tm1O7FmoMX/m45TRGoMEbNRFdYyAj89bRyBS
# 3L+ca3mMIlieu4gs0HC99w9X3DLdoDHXDs/PgnyffKgxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAbn2AA1lVE+8AwABAAAB
# uTANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCC30LsSQb48qpMaUPIfgH44lUpat6YGuknepYKdcOv7
# sTCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIGTrRs7xbzm5MB8lUQ7e9fZo
# tpAVyBwal3Cw6iL5+g/0MIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAG59gANZVRPvAMAAQAAAbkwIgQgGZtAzWIsdL7/yvvUkymRLmbf
# BrDWQ169QDhNZFNrZDAwDQYJKoZIhvcNAQELBQAEggIAFUA4aucHWjvtNDbIsPkP
# D6qvCDqPHzYSIopGMEsm7cUGIFJDcGI7P3GH8fcsZkxDlGXKzhgdq7c1RhH5GhP1
# rd4k1z2lEJmno0ra9HoJbjuya4RiCnMnDQeC2WvmYMp43REdGT1KFlj2CGPA3ocy
# 4seU8wlpgMns+7BtCJwCD2mP44U8U5D6CC0lcti69Y+5nSZIz96xQsiAie3p09hz
# ETxYiAQDk/mu3gpc7EQy/CR+nGroq0S1NcH7/MjW57Z3MGXufWlP/7Jxjrw/Jjwk
# 9XoKC9xeMCFhTVg5KOLghbquIFldXv3bJv7ABQHeyd8i1UhQqipsqMxJ4lvfJuKE
# 2lEJpphKCZnjiBwvyMuQI/SFRrykVuHExs3VsHhH2bOFzDtN4FvO7AcLSUSAFLzr
# uYFUf5QA948JQYQzsahR4ArYMSXaw8r0pGvjEikRdqbh88zdpkMdEFq4cArLHZA0
# KRuoevRfTvE/9Zzo85xEvQts0RYSmgIhM67tq9lTBT9BEoJJQp/aCGeo8nNNAxCz
# n2CGcQkJikGnb+9tyk/zjCIphoDHqrEMEl+VgDdImfToJKaeo3DB3VLnEm/Y7M8j
# 72xchq8EYiYQT51UYyUjmh/V/zoJBqahoQTmcTWyW6oov5hF78MCd+BRDQXUMtgG
# RehIuqk9umE0DLxVoMg3uL8=
# SIG # End signature block
