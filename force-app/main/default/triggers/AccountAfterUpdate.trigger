trigger AccountAfterUpdate on Account (after update) {
    AccountUpdateCounterHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
}
