public class SampleRSSOverrideTesting implements Dm_ComputeStrategy_Interface {
    public List<DM_Repayment_Schedule_Summary__c> computeRSS(Id ParentId){
        system.debug('inside computeRSS');
        List<DM_Repayment_Schedule_Summary__c> returnRSSList = new List<DM_Repayment_Schedule_Summary__c>();
        List<DM_Repayment_Schedule_Summary__c> rssList = [select id from DM_Repayment_Schedule_Summary__c where DM_CL_Contract__c =: parentId];
        if(!rssList.isEmpty()){
            for(DM_Repayment_Schedule_Summary__c rss1 : rssList ){
                rss1.DM_Custom_Field_1__c ='WhooAAAA';
                returnRSSList.add(rss1);
            }
        }
        return returnRSSList;
    }
    public List<dm_Loan_Payment_Transaction__c> computeLPT(Id ParentId){
        List<dm_Loan_Payment_Transaction__c> lptList = new List<dm_Loan_Payment_Transaction__c>();
        return lptList;
    }
    public List<dm_Loan_Disbursal_Transaction__c> computeLDT(Id ParentId){
         List<dm_Loan_Disbursal_Transaction__c> ldtList = new List<dm_Loan_Disbursal_Transaction__c>();
         return ldtList;
    }
    public List<DM_Bill__c> computeBill(Id ParentId){
        List<DM_Bill__c> billList = new List<DM_Bill__c>();
        return billList;
    }
    public List<DM_Charge__c> computeCharge(Id ParentId){
        List<DM_Charge__c> chargeList = new List<DM_Charge__c>();
         return chargeList;
    }
    public List<DM_Automated_Payment_Setup__c> computeAPS(Id ParentId){
         List<DM_Automated_Payment_Setup__c> APSList = new List<DM_Automated_Payment_Setup__c>(); 
         return APSList;
    }
    public List<DM_Repayment_Schedule__c> computeRS(Id ParentId){
        List<DM_Repayment_Schedule__c> amzList = new List<DM_Repayment_Schedule__c>();
         return amzList;
    }
}