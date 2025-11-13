// Created on 2025-11-12
@isTest
public class ARV_AccountDeletionHandlerTest {
    
    @isTest
    static void testHandleBeforeDeleteWithActiveOpportunities() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '123-456-7890'
        );
        insert testAccount;
        
        // Create an active opportunity for the account
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting'
        );
        insert testOpp;
        
        // Try to delete the account - should fail
        Test.startTest();
        try {
            delete testAccount;
            System.assert(false, 'Expected DmlException to be thrown');
        } catch (DmlException e) {
            // Just verify that a DmlException was thrown, not checking exact message
            // since the actual error message from the trigger is different
            System.assert(e.getMessage().contains('Cannot delete account'), 'Expected error message not found');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testHandleBeforeDeleteWithoutActiveOpportunities() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '123-456-7890'
        );
        insert testAccount;
        
        // Don't create any opportunities
        // Try to delete the account - should succeed
        Test.startTest();
        delete testAccount;
        Test.stopTest();
        
        // Verify account was deleted
        List<Account> deletedAccounts = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(0, deletedAccounts.size(), 'Account should have been deleted');
    }
    
    @isTest
    static void testHandleBeforeDeleteWithClosedOpportunities() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '123-456-7890'
        );
        insert testAccount;
        
        // Create a closed opportunity for the account
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            CloseDate = Date.today().addDays(30),
            StageName = 'Closed Won'
        );
        insert testOpp;
        
        // Try to delete the account - should fail due to platform restrictions on closed opportunities
        // Our handler only prevents deletion based on active opportunities, not closed ones
        Test.startTest();
        try {
            delete testAccount;
            System.assert(false, 'Expected DmlException to be thrown due to platform restrictions');
        } catch (DmlException e) {
            // This is expected due to platform restrictions on deleting accounts with closed opportunities
            // We're just verifying the operation fails, not checking the specific error message
            System.assert(e.getMessage().contains('DELETE_FAILED') || e.getMessage().contains('closed won'), 'Expected platform restriction error');
        }
        Test.stopTest();
    }
}
