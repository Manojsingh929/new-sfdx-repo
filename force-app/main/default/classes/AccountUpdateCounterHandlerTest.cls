@IsTest
private class AccountUpdateCounterHandlerTest {

    @IsTest
    static void testSingleUpdateIncrementsCounter() {
        Account a = new Account(Name = 'Acme Co');
        insert a;

        // Counter should be null initially
        a.Name = 'Acme Co Updated hello';
        update a;

        // Reload and assert counter incremented to 1
        Account reloaded = [SELECT Id, AccountUpdateCounter__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(1, (Integer)(reloaded.AccountUpdateCounter__c == null ? 0 : reloaded.AccountUpdateCounter__c), 'Counter should be 1 after first update');

        // Update a different field again; expect counter increments to 2
        reloaded.Phone = '1234567890';
        update reloaded;

        Account reloaded2 = [SELECT Id, AccountUpdateCounter__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(2, (Integer)reloaded2.AccountUpdateCounter__c, 'Counter should be 2 after second update');
    }

    @IsTest
    static void testBulkUpdateIncrementsEachOnce() {
        List<Account> accts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accts.add(new Account(Name = 'Bulk ' + i));
        }
        insert accts;

        for (Account a : accts) {
            a.Industry = 'Technology';
        }
        update accts;

        Map<Id, Account> results = new Map<Id, Account>([SELECT Id, AccountUpdateCounter__c FROM Account WHERE Id IN :accts]);
        for (Account a : accts) {
            Account got = results.get(a.Id);
            System.assertEquals(1, (Integer)(got.AccountUpdateCounter__c == null ? 0 : got.AccountUpdateCounter__c), 'Each record should be incremented once');
        }
    }

    @IsTest
    static void testSkipWhenOnlyCounterChanges() {
        Account a = new Account(Name = 'Only Counter Change');
        insert a;

        // Manually set counter to some value and update ONLY the counter.
        a = [SELECT Id, AccountUpdateCounter__c FROM Account WHERE Id = :a.Id];
        a.AccountUpdateCounter__c = 10;
        update a;

        // Handler should skip because only counter changed; it should remain 10.
        Account after = [SELECT Id, AccountUpdateCounter__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(10, (Integer)(after.AccountUpdateCounter__c == null ? 0 : after.AccountUpdateCounter__c), 'Counter should not auto-increment when only the counter changed');

        // Now change another field; expect increment to 11
        after = [SELECT Id, Name, AccountUpdateCounter__c FROM Account WHERE Id = :a.Id];
        after.Name = 'Changed';
        update after;

        Account finalAcc = [SELECT Id, AccountUpdateCounter__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(11, (Integer)finalAcc.AccountUpdateCounter__c, 'Counter should increment when another field changes');
    }
}
