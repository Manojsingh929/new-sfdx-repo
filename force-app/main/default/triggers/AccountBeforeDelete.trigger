trigger AccountBeforeDelete on Account (before delete) {
    ARV_AccountDeletionHandler.handleBeforeDelete(Trigger.old);
}
