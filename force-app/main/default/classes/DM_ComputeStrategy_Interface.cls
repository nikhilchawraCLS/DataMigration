Global interface DM_ComputeStrategy_Interface {
    List<DM_Repayment_Schedule_Summary__c> computeRSS(Id ParentId);
    List<dm_Loan_Payment_Transaction__c> computeLPT(Id ParentId);
    List<dm_Loan_Disbursal_Transaction__c> computeLDT(Id ParentId);
    List<DM_Bill__c> computeBill(Id ParentId);
    List<DM_Charge__c> computeCharge(Id ParentId);
    List<DM_Automated_Payment_Setup__c> computeAPS(Id ParentId);
    List<DM_Repayment_Schedule__c> computeRS(Id ParentId); 
}