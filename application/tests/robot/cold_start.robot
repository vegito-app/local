*** Settings ***
Library           SeleniumLibrary
Library           Firebase
Library           OperatingSystem
Suite Setup       Reset Firestore And Users Before Test
Test Setup        Close All Browsers

*** Test Cases ***
App Cold Start With Anonymous User
    [Documentation]    Simule une réinstallation de l'application avec un utilisateur anonyme existant.
    # Étapes placeholder à compléter plus tard
    Log    Simulation d’un redémarrage à froid avec UID anonyme


# -- Pseudo scénarios à implémenter --

# [TODO] App Reinstall After Anonymous User Creation
# Simule une désinstallation + réinstallation de l'app et vérifie si un nouveau compte anonyme est créé ou si l'ancien est restauré via session locale.

# [TODO] Restore Anonymous Session From Local Cache
# Précondition : un compte anonyme existe et l'app a déjà été lancée.
# Redémarrer l'app et vérifier que l'utilisateur n'est pas recréé.

# [TODO] Cold Start After Local Cache Purge
# Supprimer cache/app data côté Android, relancer, vérifier qu'un nouveau compte est généré.

# [TODO] Persist App Data Across Cold Restarts
# Créer un objet lié au compte anonyme, redémarrer l'app, vérifier que l'objet est toujours là.

# [TODO] Connect Using Custom Token For Controlled UID
# Générer un token de connexion depuis le SDK admin, injecter dans l'app, vérifier que le bon UID est utilisé.
