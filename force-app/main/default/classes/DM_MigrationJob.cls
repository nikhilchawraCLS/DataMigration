Global class DM_MigrationJob implements Database.Batchable<sObject> 
{    
    public String migrationBatchType;
    public static String migrationBatchType;
    public List<DM_Loan_Account__c> errorUpdate = new List<DM_Loan_Account__c>();
    public List<Dm_ValidationWrapper> validationWrapperList = new List<DM_ValidationWrapper>();
    public DM_Metadata_Config_Wrapper configWrapper;
  
    global DM_MigrationJob(){
         //call the class and initialize the wrapper instance here.
         configWrapper = ParserUtil.getParser();         
    }
    global DM_MigrationJob(String batchType){
        configWrapper = ParserUtil.getParser(); 
        migrationBatchType = batchType;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        DM_SqlQueryGenerator sqlQuery = new DM_SqlQueryGenerator();        
        return Database.getQueryLocator(sqlQuery.GetQueryString('DM_Repayment_Schedule_Summary__c;DM_Loan_Payment_Transaction__c;DM_Loan_Disbursal_Transaction__c;DM_Charge__c;DM_Bill__c;DM_Automated_Payment_Setup__c;DM_Repayment_Schedule__c;DM_Loan_Account__c',migrationBatchType));
    }//END start

    global void execute(Database.BatchableContext BC, List<DM_Loan_Account__c> dmList) 
    {
        system.debug('scope list '+dmList.size()+ 'list '+dmList);
        Boolean dataCreationFlag = false; 
        
        DM_Validate_Impl handler = new DM_Validate_Impl();
        system.debug('configWrapper '+configWrapper);
        validationWrapperList = handler.validateDMRules(dmList,configWrapper);
        system.debug('validation Wrapper List Result '+validationWrapperList);
        DM_Data_Creation dataCreation;
        For(DM_ValidationWrapper valWrapper : validationWrapperList){
            if(valWrapper.Success){
                system.debug('validation Wrap Success');
                dataCreationFlag = true;
            }else{
                dataCreationFlag = false;
                //failed valWrapper send for updation
                system.debug('DM CL contract '+dmList[0]);
                errorUpdate.add(new DM_Loan_Account__c(Id=dmList[0].Id, DM_Error__c= valWrapper.errorMessage, DM_Invalid_Data__c=True, migration_status__c='Failed'));
                system.debug('Failed');
                break;
            }//END Else
        }//END For 
        
        system.debug('update Failed Record '+errorUpdate);
        if(!errorUpdate.isEmpty())
        	update errorUpdate;
            
        if(dataCreationFlag){
            system.debug('dataCreationFlag - True');
            dataCreation = new DM_Data_Creation();
            dataCreation.DataCreation(dmList);
            system.debug('dataCreation Exit');
        }//END IF(dataCreationFlag)
    }//END execute
    
    global void finish(Database.BatchableContext BC) {
         system.debug('Finish Batch Job');
    }//END finish
}//END DM_MigrationJob