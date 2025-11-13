public with sharing class AccountUpdateCounterHandler {
    // recursion guard so we only perform one extra update per transaction other change
    private static Boolean hasRun = false;

    public static void handleAfterUpdate(List<Account> newList, Map<Id, Account> oldMap) {
        if (hasRun || newList == null || newList.isEmpty()) {
            return;
        }
        hasRun = true;

        List<Account> toUpdate = new List<Account>();

        for (Account a : newList) {
            Account oldA = oldMap.get(a.Id);

            // Increment on any update EXCEPT when the only field changed is the counter itself.
            Boolean onlyCounterChanged = false;
            if (oldA != null) {
                Boolean counterChanged = (a.AccountUpdateCounter__c != oldA.AccountUpdateCounter__c);

                // Detect if any other commonly edited fields changed.
                Boolean someOtherChanged = false;
                if (a.Name != oldA.Name) someOtherChanged = true;
                else if (a.Phone != oldA.Phone) someOtherChanged = true;
                else if (a.Industry != oldA.Industry) someOtherChanged = true;
                else if (a.Type != oldA.Type) someOtherChanged = true;
                else if (a.OwnerId != oldA.OwnerId) someOtherChanged = true;

                // If counter changed and no other detected field changed, treat as only-counter change.
                onlyCounterChanged = counterChanged && !someOtherChanged;
            }

            if (onlyCounterChanged) {
                // Skip to prevent recursion and false counting when only the counter changed
                continue;
            }

            Decimal current = (a.AccountUpdateCounter__c == null) ? 0 : a.AccountUpdateCounter__c;
            Account upd = new Account(
                Id = a.Id,
                AccountUpdateCounter__c = current + 1
            );
            toUpdate.add(upd);
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
}
