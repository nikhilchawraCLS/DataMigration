global class DM_Validate_Impl extends DM_ValidationAbstract {
    global List<Dm_ValidationWrapper> validationWrapperList = new List<DM_ValidationWrapper>(); 
    global static Map<String,String> loanTypeAndSrcObj_StrategyMap = new Map<String,String>();
    global static Map<String,String> loanTypeAndSrcObj_StrategyClass = new Map<String,String>();
    public List<DM_ValidationWrapper> validateDMRules(List<DM_Loan_Account__c> dmList, DM_Metadata_Config_Wrapper configWrapper)
    {
        system.debug('Inside ValidateDMRules');      
        system.debug('configWrapper'+configWrapper);
        For(DM_Metadata_Config_Wrapper.ForEachLendingProduct lendingProd : configWrapper.DM_Metadata_Config.ForEachLendingProduct){
            for(DM_Metadata_Config_Wrapper.config config :lendingProd.config){
                loanTypeAndSrcObj_StrategyMap.put(lendingProd.name+'|'+config.srcObj,config.strategy);
                loanTypeAndSrcObj_StrategyClass.put(lendingProd.name+'|'+config.srcObj,config.strategyClass);
            }
        }
        String objName;
        system.debug('calling ValidateDM method');
        validationWrapperList.addAll(ValidateDm(dmList,configWrapper));
      
        return validationWrapperList;
    }// abstract public DM_ValidationWrapper LoanContractValidation(DM_Loan_Account__c sRecord);
    
    public override List<DM_ValidationWrapper> runAdditionalValidationRules(List<DM_Loan_Account__c> dmList, DM_Metadata_Config_Wrapper configWrapper){
        system.debug('Inside runAdditionalValidationRules');

        //Additional Implementation
        return validationWrapperList;
    }
    
    public static Map<String, Map<String, String>> getFieldMappingFromJSON(DM_Metadata_Config_Wrapper configWrapper){
        Map<String, Map<String, String>> JSONFieldMapping = new Map<String, Map<String, String>>();
        Map<String,String> tempMap = new Map<String,String>();
        Integer i=0;
        for(DM_Metadata_Config_Wrapper.ForEachLendingProduct lendingProd : configWrapper.DM_Metadata_Config.ForEachLendingProduct){
            for(DM_Metadata_Config_Wrapper.config config :lendingProd.config){
                for(DM_Metadata_Config_Wrapper.FieldMapping fm : config.fieldMapping){
                    system.debug('fieldMapping'+fm);
                    if(!JSONFieldMapping.containsKey(lendingProd.name+'|'+config.srcObj)){
                        tempMap.put(config.srcObj+'|'+fm.srcField,config.trgObj+'|'+fm.trgField+'|'+fm.dataType);
                        JSONFieldMapping.put(lendingProd.name+'|'+config.srcObj,tempMap);    
                    }else{
                        system.debug('JSONFieldMapping key found');
                        tempMap.put(config.srcObj+'|'+fm.srcField,config.trgObj+'|'+fm.trgField+'|'+fm.dataType);
                        JSONFieldMapping.get(lendingProd.name+'|'+config.srcObj).putAll(tempMap);   
                    } 
                }//FieldMapping Loop
            }//Config loop
            tempMap = new Map<String,String>();
        }//Lending Product Loop
        system.debug('JSON return '+JSONFieldMapping);
        return JSONFieldMapping;
    }//END Method getFieldMappingFromJSON
}//END Class DM_Validate_Impl