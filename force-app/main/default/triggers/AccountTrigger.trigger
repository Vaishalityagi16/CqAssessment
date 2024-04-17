trigger AccountTrigger on Account (before Insert, After Insert, before Update) {
    if(trigger.isbefore){
        if(trigger.isInsert){
            AccountTriggerController.checkActiveAccountValidation(Trigger.New);
        }
        else if(trigger.isUpdate){
            AccountTriggerController.checkAccountValidationOnUpdate(Trigger.New);
        }
    }
    else if(trigger.isAfter){
        if(trigger.isInsert){
            AccountTriggerController.createTeamMembersRelatedAccount(Trigger.New);
        }
    }
}