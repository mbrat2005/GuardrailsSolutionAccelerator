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
bgProcedure = Procédure de compte Brise Glass
bgCreation = Création de compte Brise Glass
bgAccountResponsibility = La responsabilité des comptes bris de glace doit incomber à une personne non technique, de niveau directeur ou supérieur
bgAccountOwnerContact = Coordonnées des titulaires de compte Brise Glass
bgAccountsCompliance = {0} Statut de conformité = {1}, {2} Statut de conformité = {3}
bgAuthenticationMeth =  Méthodes d'authentification 
bgLicenseNotAssigned = NON ASSIGNÉ
bgAssignedLicense =  Licence attribuée = 
bgAccountHasManager = Le compte BG {0} a un responsable
bgAccountNoManager =  Le compte BG {0} n'a pas de gestionnaire 
bgBothHaveManager =  Les deux comptes BreakGlass ont un gestionnaire

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
networkDiagram = Existence d'un diagramme d'architecture réseau 

# GuardRail # 9
vnetDDosConfig = Configuration DDos VNet
ddosEnabled = Protection DDos activée. 
ddosNotEnabled = Protection DDos non activée.

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
# MIInyQYJKoZIhvcNAQcCoIInujCCJ7YCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAwLCO0ExnMmey4
# HGiQKGdyIu5UxpufrL9yePynhXFNKaCCDYEwggX/MIID56ADAgECAhMzAAACzI61
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
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZnjCCGZoCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAsyOtZamvdHJTgAAAAACzDAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgs1fjRo4v
# A8VCgle9Dkx6yobtpdnY3vD8s9SooXhgM5kwQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQAsDv+32fALYc/DcJTvOwM6e1D94EGkKLzbA/KiFLch
# gR6m+rKIRa0ta6QX+4Ciu6V8UGruADVVXCnyUgvz3P0uZMgQ4XhO3jQk/sPjVPBp
# a/cozmexJ51p0YjcxmNhdliP90pVJQtl7NplI+QSilvZ7hgtLt48HXoE5UdQgS49
# IUhddjcq5ptFiauwBhS/Qu/tb8N8Km/nAbQ8sDxUT7GGh17IcXpYHXzOexF9+VuA
# WIfh09lw9lx5jZjS/t75nrtxi9C+FA8SMsrsaGuM/1RfszLriOTH7CysZqUu5cA4
# D7k84Xl0dTWhjFUOOvBIVV6myqT+ZtJmCJxLdl6Maj76oYIXKDCCFyQGCisGAQQB
# gjcDAwExghcUMIIXEAYJKoZIhvcNAQcCoIIXATCCFv0CAQMxDzANBglghkgBZQME
# AgEFADCCAVgGCyqGSIb3DQEJEAEEoIIBRwSCAUMwggE/AgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIA4tH8NBdXYi2cSdGn7/kx89k7ZztJzNvJWzRR/f
# I/drAgZjN1HRAjgYEjIwMjIxMDAzMjIyMzQxLjA3WjAEgAIB9KCB2KSB1TCB0jEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWlj
# cm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFs
# ZXMgVFNTIEVTTjozQkQ0LTRCODAtNjlDMzElMCMGA1UEAxMcTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgU2VydmljZaCCEXgwggcnMIIFD6ADAgECAhMzAAABtPuACEQF0i36
# AAEAAAG0MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
# MDEwMB4XDTIyMDkyMDIwMjIwOVoXDTIzMTIxNDIwMjIwOVowgdIxCzAJBgNVBAYT
# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJ
# cmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBF
# U046M0JENC00QjgwLTY5QzMxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFNlcnZpY2UwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC0R6aeZQcy
# Qh+86K7bsrzplvBaGSwbBXvYOXW4Z2qvakqb6Z/OhP5ieCSr1osR/5cO0APID7Yo
# hlTSI7xYbv14mPPPb1+VmkEpsqDzGXY/c712uV65DDdOc1803j5AiCMxekTe3E8X
# szshEspkyI63cV+QVZWaJckADsTc4jAmCmGDT22HdO/OnwxPz4c60bdt2tF3/La7
# xWtCxBMtmJXBNnqoNgo1Pw9BmXvEWtJI7dDNdr3UuKlmdg6XeyIYkMJ57UFrtfWL
# Xd1AUfEqXkV/gnMN244Fnzl7ZWunIXLVrdrIZTMGsjDn2OExuMjD1hVxC32RRae3
# IKY2TXlbJsJL6FekQMMtWPVflb2yeahbWq7Tf66emtCNZBpW47sF9y9B01V3IpKo
# B4rLV5PYdxzmfVoBV5cWbqxtUmZnM9ARBHcmvtbxhxOOSoLmFPaqti4hxgY5/c+P
# g6p1ebVCqG7C2yTG+K/vLLdn4/EmnErH7Z7rMZFqhCYiUt+D9rjZc1UdN/pbOvmT
# tDXDu/S4D+wWyDIqYjsfModfTzEMNKYmihcDlu0PoHSXH8uqzpBvgq2GcDs3YgR0
# nmyMwiHIdnAGvt/MOyRT/5KCnZSd+qs3VV1r+Bv6maVsnCLwymG8SVjONPs9krYO
# bh6ityPHtPZBV7cQh6Uu4ZvHPJtuVmhFOQIDAQABo4IBSTCCAUUwHQYDVR0OBBYE
# FMtEheXxlLg6nLsSKLdO3jjMMtl+MB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWn
# G1M1GelyMF8GA1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNv
# bS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEw
# KDEpLmNybDBsBggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFt
# cCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAww
# CgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQAS
# 0Q8FjCm3gmKhKrSOgbPCphfpKg0fthuqmACt2Wet23q7e6QpESW4oRWpLZdqNfHH
# RSRcZzheL12nZtLGm7JCdOSr4hDCSDunV0qvABra92Zo3PPeatJp5QS7jTIJOEfC
# q5CTB6gbh6pFFl7X061VKYMM0LdlDoiDSrPv2+K9eDLl0VaTienEDkvFIZHjAFpd
# oi5WGgRrTq93/3/ZixD31sKJHtLElG3VetDmQkYdSLQWGDPXnyq9eB+aruo2p+p9
# NKaxBGu1t7hm/9f6o+j+Xpp75KsuRyNF+vQ41XS8VW40rHoJv3QPkuA2lz3HxX+o
# gcSv4ldtZdbqYBFVWo1AKZeVUeNMGOFxfBKZp1HU6i1w3+wqnYQ4z0k9ivzo71j8
# kBkL3O6D2qWMpOuhlN9gDssh1yY+vr27UVIP/qK8vodEdl3+TYQvsW1nDM1xFF0U
# X9WCmQ7Ech+q+NdqZvCgyhP6+0ZO2qCiu6GFKTRszUX+kGmL+c9m1U0sZM1orxa3
# qSxxsL0bp/T2DP/AEEk4Ga9Ms845P/e1oIZKgmgMAFacr4N7mmJ7gpfwHHEpBsm/
# HPu9GxUnlHqYbH4G9q/kCOzG9lnDp5CaQjS89FyTEv1MJUJ9ZLS7IgqbKjpN2iyd
# sE7+iyt7uvSNL0AfyykSpWWEVylA186D8K91LbE1UzCCB3EwggVZoAMCAQICEzMA
# AAAVxedrngKbSZkAAAAAABUwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290
# IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMw
# MDkzMDE4MzIyNVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggIiMA0G
# CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDk4aZM57RyIQt5osvXJHm9DtWC0/3u
# nAcH0qlsTnXIyjVX9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1
# jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N7dcP2CZT
# fDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+
# jlPP1uyFVk3v3byNpOORj7I5LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJj361VI/c
# +gVVmG1oO5pGve2krnopN6zL64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+
# cakXW2dg3viSkR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX782Z5F37ZyL9t9X4C6
# 26p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV
# 2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoS
# CtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxS
# UV0S2yW6r1AFemzFER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode2o+eFnJp
# xq57t7c+auIurQIDAQABo4IB3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEAATAjBgkr
# BgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0A
# XmJdg/Tl0mWnG1M1GelyMFwGA1UdIARVMFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYI
# KwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9S
# ZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3FAIE
# DB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNV
# HSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVo
# dHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29D
# ZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAC
# hj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1
# dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwEx
# JFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0xM7U518JxNj/aZGx80HU5bbsPMeTCj/ts
# 0aGUGCLu6WZnOlNN3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu2D9I
# dQHZGN5tggz1bSNU5HhTdSRXud2f8449xvNo32X2pFaq95W2KFUn0CS9QKC/GbYS
# EhFdPSfgQJY4rPf5KYnDvBewVIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMu
# LGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT9
# 9kxybxCrdTDFNLB62FD+CljdQDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2z
# AVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRrakURR6nxt67I6Ile
# T53S0Ex2tVdUCbFpAUR+fKFhbHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6l
# MVGEvL8CwYKiexcdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVnK+ANuOaMmdbh
# IurwJ0I9JZTmdHRbatGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3u
# gm2lBRDBcQZqELQdVTNYs6FwZvKhggLUMIICPQIBATCCAQChgdikgdUwgdIxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jv
# c29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhhbGVz
# IFRTUyBFU046M0JENC00QjgwLTY5QzMxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAGWc2JDzm5f2c3gpEm3+AeQn
# HgkIoIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJKoZI
# hvcNAQEFBQACBQDm5cTGMCIYDzIwMjIxMDA0MDQyOTU4WhgPMjAyMjEwMDUwNDI5
# NThaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOblxMYCAQAwBwIBAAICEpEwBwIB
# AAICEWkwCgIFAObnFkYCAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoD
# AqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG9w0BAQUFAAOBgQBOrXLN
# JSi+JHQ4+k3MwFeXXwULmAkEN68ezxGc7Y65+MyFVCuw13EKqZNKh/EPBu+5Nt/K
# mJty6IrzlMYe5YbPegTP0oYOraGsGB4Tgz08SN68lEf6ck4A79LyQ+8u5ZjzWi3+
# DR2ZihetfXGoRlOo8nAy+0qH9dJ72JDDDHk8eDGCBA0wggQJAgEBMIGTMHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABtPuACEQF0i36AAEAAAG0MA0G
# CWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJ
# KoZIhvcNAQkEMSIEICn3FO7CqLQWaMIwLw9YZ8GEgO4lGhm+qyxXlevOxr+iMIH6
# BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQg08j3e+ajMHAGUXG9+v+sSWt4U9Hi
# 7Hu9crHaeLcB9wYwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MAITMwAAAbT7gAhEBdIt+gABAAABtDAiBCDRBiJP2VUyTYIQXKRGiQ/L1BNp01/V
# k0/DyRU4UI3yyDANBgkqhkiG9w0BAQsFAASCAgCKzBI1yD7RnInlhX4xnbli6oCV
# V3x7BqzUxccPI+pUp6kX/Q8J2P9O1weLInMifPzW+M625N8dfHowNUPiSKVuW7vn
# jhLZrIlUceJnRJoAL6F2T/wDJoh1De32wPBQwIYAvnJbV9a+UTXv8TmNARbWeAPC
# mEaflBy6deXEQB3lVBKbnRStr86c7zl7bQks/fco4XEqn6xnu47mivuSRpRXS+tg
# /68goSF8wVB7wpDYwDpmQ0D2sgGgqM5IOlOA672n6Fgl4mCyu4bluVWXJA4Zmpux
# C9lCP0RtRejYmkPg8PNGi2VvGECPHODPFA0t5sRRAQxCm2x6CrkYJwG/pdGXTo9r
# iO/OnVlDq404nwcJ1MVa/bNdcX4zfCtuOLFL29UlHA0O9tXUryU3+YBj5YFMmmVn
# Svf2XqW+H1I3fZDKh9XGxYF0IMnVCfPAHmnG9b4n3pRvlGy5VHa3FCokiwyZ7gRb
# zvUWfe38E5hh3zcyIg/5GqaF/2rranH+DMiMlZhb1EHeO92fw9IEBH0Sv3Zb3U3B
# tcOZ1sMC2nI/vOxvMJJ6MioHqz4TKg+WeoYvgX97qfbBh5+f8A/PoCwkPh3Zn8zs
# AkF88s0n7oBj/wqhiNT1ximKtMgmHjaYWYxTjrkQ2k3ykzV4ujBBG7gAC1E9mUyr
# 4ouo2tnhs4mLBCba0w==
# SIG # End signature block
