// Created on 2025-11-12
@IsTest
private class ARV_ContactActivitySanitizerTest {
    @IsTest
    static void testInactivateActiveContactsWithBlankFirstName_updatesWhenBlankAndActive() {
        // "Active" = DoNotCall == false; "Inactive" = DoNotCall == true
        Contact c1 = new Contact(LastName = 'L1', FirstName = null, DoNotCall = false);
        Contact c2 = new Contact(LastName = 'L2', FirstName = 'John', DoNotCall = false);
        Contact c3 = new Contact(LastName = 'L3', FirstName = '', DoNotCall = true);
        insert new List<Contact>{ c1, c2, c3 };

        Test.startTest();
        List<Contact> updated = ARV_ContactActivitySanitizer.inactivateActiveContactsWithBlankFirstName(
            new Set<Id>{ c1.Id, c2.Id, c3.Id }
        );
        Test.stopTest();

        System.assertEquals(1, updated.size(), 'Only one contact should be updated (c1).');

        // Requery to verify persisted values
        Map<Id, Contact> afterMap = new Map<Id, Contact>([
            SELECT Id, FirstName, DoNotCall FROM Contact WHERE Id IN :new Set<Id>{ c1.Id, c2.Id, c3.Id }
        ]);

        System.assertEquals(true, afterMap.get(c1.Id).DoNotCall, 'c1 should be marked inactive (DoNotCall=true).');
        System.assertEquals(false, afterMap.get(c2.Id).DoNotCall, 'c2 should remain active (DoNotCall=false).');
        System.assertEquals(true, afterMap.get(c3.Id).DoNotCall, 'c3 should remain inactive (DoNotCall=true).');
    }

    @IsTest
    static void testInactivateActiveContactsWithBlankFirstName_noDmlWhenNoneNeedChange() {
        // modified comment All records either have FirstName set or are already inactive
        Contact c1 = new Contact(LastName = 'L1', FirstName = 'Jane', DoNotCall = false);
        Contact c2 = new Contact(LastName = 'L2', FirstName = '', DoNotCall = true);
        insert new List<Contact>{ c1, c2 };

        Test.startTest();
        List<Contact> updated = ARV_ContactActivitySanitizer.inactivateActiveContactsWithBlankFirstName(
            new Set<Id>{ c1.Id, c2.Id }
        );
        Test.stopTest();

        System.assertEquals(0, updated.size(), 'No contacts should be updated.');
    }
}
