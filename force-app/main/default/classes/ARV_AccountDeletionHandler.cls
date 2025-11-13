// Created on 2025-11-12
public with sharing class ARV_AccountDeletionHandler {
    
    public static void handleBeforeDelete(List<Account> accountsToDelete) {
        // Get all account IDs that are being deleted
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accountsToDelete) {
            accountIds.add(acc.Id);
        }
        
        // Query for opportunities related to these accounts
        List<Opportunity> opportunities = [
            SELECT Id, AccountId 
            FROM Opportunity 
            WHERE AccountId IN :accountIds 
            AND IsClosed = false
        ];
        
        // Group opportunities by account ID
        Map<Id, List<Opportunity>> opportunitiesByAccount = new Map<Id, List<Opportunity>>();
        for (Opportunity opp : opportunities) {
            if (!opportunitiesByAccount.containsKey(opp.AccountId)) {
                opportunitiesByAccount.put(opp.AccountId, new List<Opportunity>());
            }
            opportunitiesByAccount.get(opp.AccountId).add(opp);
        }
        
        // Collect errors for accounts with active opportunities
        List<DmlException> errors = new List<DmlException>();
        
        // Add errors to prevent deletion of accounts with active opportunities
        for (Account acc : accountsToDelete) {
            if (opportunitiesByAccount.containsKey(acc.Id) && !opportunitiesByAccount.get(acc.Id).isEmpty()) {
                // Prevent deletion by adding an error
                throw new DmlException('Cannot delete account "' + acc.Name + '" because it has active opportunities.');
            }
        }
    }
}
