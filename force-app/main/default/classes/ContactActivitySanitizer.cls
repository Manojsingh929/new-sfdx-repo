// Created on 2025-11-12
public with sharing class ARV_ContactActivitySanitizer {
    /**
     * Inactivates Contacts that are currently active and have a blank FirstName.
     *
     * Assumptions for "active/inactive" due to absence of Contact.Active__c in target org:
     * - Treat "active" as DoNotCall == false (contactable)
     * - Mark "inactive" by setting DoNotCall = true
     * If your org has a real active/inactive field, replace DoNotCall with that field.
     *
     * Bulk-safe and idempotent. Only updates records that need change.
     *
     * @param contactIds Set of Contact Ids to evaluate. No-op if empty.
     * @return List<Contact> records updated by this method.
     */
    public static List<Contact> inactivateActiveContactsWithBlankFirstName(Set<Id> contactIds) {
        if (contactIds == null || contactIds.isEmpty()) {
            return new List<Contact>();
        }

        List<Contact> toUpdate = new List<Contact>();
        for (Contact c : [
            SELECT Id, FirstName, DoNotCall
            FROM Contact
            WHERE Id IN :contactIds
        ]) {
            Boolean isActive = c.DoNotCall == false;
            Boolean firstNameBlank = String.isBlank(c.FirstName);

            if (isActive && firstNameBlank) {
                c.DoNotCall = true; // mark as "inactive" per assumption
                toUpdate.add(c);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
        return toUpdate;
    }
}
