public class DM_Data_Creation {
    public List<DM_Loan_Account__c> errorUpdate = new List<DM_Loan_Account__c>();
    public static Id contractId;
    Savepoint sp;
    public void DataCreation(List<DM_Loan_Account__c> dmList){
        system.debug('Inside DataCreation Method');
        Id parentId;
        contractId=dmList[0].Id;
        System.debug('contract Id - '+contractId);
        parentid = insertLoanContract(dmList);
 
        system.debug('ParentId '+parentId);
        /*system.debug('child repay- '+dmList[0].DM_Repayment_Schedule_Summarys__r);
        system.debug('child ldt- '+dmList[0].dm_Loan_Disbursal_Transactions__r);
        system.debug('child lpt- '+dmList[0].dm_Loan_Payment_Transactions__r);
        system.debug('child bill- '+dmList[0].DM_Bills__r);
        system.debug('child charge- '+dmList[0].DM_charges__r);
        system.debug('child Aps- '+dmList[0].DM_Automated_Payment_Setups__r);
        system.debug('child Repayment Amort'+dmList[0].DM_Repayment_Schedules__r);*/
        if(parentId<>null){
            if(errorUpdate.isEmpty()){
                //system.debug('print map'+DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap);
                //system.debug('key - '+dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase());
                //system.debug('contains - '+DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.containsKey(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase()));
                //system.debug('get - '+DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase()));
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase())==null || DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase())=='0'){
                    system.debug('0 Strategy');
                    if(!dmList[0].DM_Repayment_Schedule_Summarys__r.isEmpty())
                        insertRepaymentSS(dmList[0].DM_Repayment_Schedule_Summarys__r,parentId);    
                }//Strategy Check - 0
                else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase()) && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase())<>null){
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule_Summary__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_rss = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Repayment_Schedule_Summary__c> computedRSSList = dm_rss.computeRSS(contractId);
                            system.debug('return list '+computedRSSList);
                            if(!computedRSSList.isEmpty())
                            insertRepaymentSS(computedRSSList,parentId);
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//End IF error Update
            
            if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase())=='0'){
                    if(!dmList[0].dm_Loan_Payment_Transactions__r.isEmpty())
                            insertLPT(dmList[0].dm_Loan_Payment_Transactions__r,parentId);
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase()) && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase())<>null){
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'dm_Loan_Payment_Transaction__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<dm_Loan_Payment_Transaction__c> computedList = dm_strategy.computeLPT(contractId);
                            system.debug('return list '+computedList);
                            if(!computedList.isEmpty())
                                insertLPT(computedList,parentId);
                        }else{
                             errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//End IF error Update
            
            if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase())=='0'){
                    if(!dmList[0].dm_Loan_Disbursal_Transactions__r.isEmpty())
                        insertLDT(dmList[0].dm_Loan_Disbursal_Transactions__r,parentId);
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase()) && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase())<>null){
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Loan_Disbursal_Transaction__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Loan_Disbursal_Transaction__c> computedList = dm_strategy.computeLDT(contractId);
                            system.debug('return list '+computedList);
                            if(!computedList.isEmpty())     
                                insertLDT(computedList,parentId);
                        }else{
                          	errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//End IF error Update
            
            if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase())=='0'){
                    if(!dmList[0].DM_Bills__r.isEmpty())
                		insertBill(dmList[0].DM_Bills__r,parentId);
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase()) && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase())<>null){
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Bill__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Bill__c> computedList = dm_strategy.computeBill(contractId);
                            system.debug('return list Bill'+computedList);
                            if(!computedList.isEmpty())     
                                insertBill(computedList,parentId);
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//END Empty ErrorUpdate
            
            if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase())=='0'){
                     if(!dmList[0].DM_Charges__r.isEmpty())
                		insertCharge(dmList[0].DM_Charges__r,parentId);
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase()) && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase())<>null){
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Charge__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Charge__c> computedList = dm_strategy.computeCharge(contractId);
                            system.debug('return list Charge'+computedList);
                            if(!computedList.isEmpty())     
                                insertCharge(computedList,parentId);
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//END Empty ErrorUpdate
          	if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase())=='0'){
                     if(!dmList[0].DM_Automated_Payment_Setups__r.isEmpty())
                		insertAPS(dmList[0].DM_Automated_Payment_Setups__r,parentId);
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase()) && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase())<>null){
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Automated_Payment_Setup__c'.toLowerCase());
                        system.debug('className'+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Automated_Payment_Setup__c> computedList = dm_strategy.computeAPS(contractId);
                            system.debug('return list APS'+computedList);
                            if(!computedList.isEmpty())     
                                insertAPS(computedList,parentId);
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//END Empty ErrorUpdate
            
            if(errorUpdate.isEmpty()){ 
                if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase())=='0'){
                     if(!dmList[0].DM_Charges__r.isEmpty()	)
                		insertRepaySchedule(dmList[0].DM_Repayment_Schedules__r,parentId);
                }else if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyMap.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase())=='1000'){
                    system.debug('Strategy 1000');
                    if(DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.containsKey(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase()) && DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase())<>null){
                        String className = DM_Validate_Impl.loanTypeAndSrcObj_StrategyClass.get(dmList[0].Product_Type__c+'|'+'DM_Repayment_Schedule__c'.toLowerCase());
                        system.debug('className '+className);
                        List<ApexClass> validateClass = [select id from ApexClass where Name= :className];
                        system.debug('validateClass');
                        if(!validateClass.isEmpty()){
                            Type customType = Type.forName(className);
                            DM_ComputeStrategy_Interface dm_strategy = (DM_ComputeStrategy_Interface)customType.newInstance();   
                            List<DM_Repayment_Schedule__c> computedList = dm_strategy.computeRS(contractId);
                            system.debug('return list APS'+computedList);
                            if(!computedList.isEmpty())     
                                insertRepaySchedule(computedList,parentId);
                        }else{
                            errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Class Mentioned in Metadata is Invalid', DM_Invalid_Data__c=True, migration_status__c='Failed'));
                        }
                    }//GET Class Name   
                }//Strategy Check - 1000
            }//END Empty ErrorUpdate
        }//END if
        
        if(!errorUpdate.isEmpty()){
            update errorUpdate;
        }else{
            Dm_Loan_Account__c dmLoan = new Dm_loan_Account__c(Id= dmList[0].Id, migration_status__c='Success', DM_Error__c='', DM_Invalid_Data__c=false, DM_Is_Migrated__c=True, Migrated_CL_Contract__C=parentId);
            update dmLoan;
        }
    }//Data Creation
    
    private Id insertLoanContract(List<DM_Loan_Account__c> dmList){
        system.debug('insertLoanContract');
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        loan__Loan_Account__c loan;
        List<loan__Loan_Account__c> loanList = new List<loan__Loan_Account__c>();
        if(!dmList.isEmpty()){
            for(DM_Loan_Account__c dmloan : dmList){
               loan = dmHandler.Dm_FieldMapping_LoanAccount(dmloan);
                system.debug('loan after mapping'+loan);
                if(loan<>null)
                    sp = Database.setSavepoint();
                    loanList.add(loan);
            }    
            try{
                if(!loanList.isEmpty()){
                    insert loanList;
                    return loanList[0].Id;
                }     
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - CL Contract - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
               return null;
            }//END Catch  
        }//END if(!dmList.isEmpty()){  
        return null;
    }//END insertLoanContract
    
    private void insertRepaymentSS(List<DM_Repayment_Schedule_Summary__c> dm_Rss, Id parentId){
        loan__Repayment_Schedule_Summary__c rss;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Repayment_Schedule_Summary__c> rssList = new List<loan__Repayment_Schedule_Summary__c>();
        if(!dm_Rss.isEmpty()){
            for(DM_Repayment_Schedule_Summary__c dmrss : dm_Rss){
               system.debug('dm rss'+rss);
               rss = dmHandler.DM_StaticFieldMapping_rss(dmrss,parentId);
               system.debug('rss'+rss);
                if(rss<>null)
                    rssList.add(rss);
            }    
            try{
                if(!rssList.isEmpty()){
                    //Create SavePoint
                    insert rssList;
                }     
            }catch(Exception ex){
                errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - RSS - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
         }
    }//insertRepaymentSS
    
    private void insertLDT(List<dm_Loan_Disbursal_Transaction__c> dm_ldt, Id parentId){
        loan__Loan_Disbursal_Transaction__c ldt;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Loan_Disbursal_Transaction__c> ldtList = new List<loan__Loan_Disbursal_Transaction__c>();
        if(!dm_ldt.isEmpty()){
            for(dm_Loan_Disbursal_Transaction__c dmldt : dm_ldt){
               ldt = dmHandler.DM_StaticFieldMapping_ldt(dmldt,parentId);
                if(ldt<>null)
                    ldtList.add(ldt);
            }//END For 
            try{
                if(!ldtList.isEmpty()){
                    //Create SavePoint
                    insert ldtList;
                }     
            }catch(Exception ex){
                //update the DM Record
                errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - LDT - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
         }
    }//END insertLDT
    private void insertLPT(List<dm_Loan_Payment_Transaction__c> dm_lpt, Id parentId){
        loan__Loan_Payment_Transaction__c lpt;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Loan_Payment_Transaction__c> lptList = new List<loan__Loan_Payment_Transaction__c>();
        if(!dm_lpt.isEmpty()){
            for(dm_Loan_Payment_Transaction__c dmlpt : dm_lpt){
               lpt = dmHandler.DM_StaticFieldMapping_lpt(dmlpt,parentId);
                if(lpt<>null)
                    lptList.add(lpt);
            }    
            try{
                if(!lptList.isEmpty()){
                    //Create SavePoint
                    insert lptList;
                }     
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - LPT - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
               Database.rollback(sp);
            }//END Catch   
         }
    }//END insertLPT

    private void insertBill(List<DM_Bill__c> dm_Bill, Id parentId){
        loan__Loan_account_Due_Details__c bill;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Loan_account_Due_Details__c> billList = new List<loan__Loan_account_Due_Details__c>();
        if(!dm_Bill.isEmpty()){
            for(DM_Bill__c dmBill : dm_Bill){
               bill = dmHandler.DM_StaticFieldMapping_bill(dmBill,parentId);
                if(bill<>null)
                    billList.add(bill);
            }    
            try{
                if(!billList.isEmpty()){
                    insert billList;
                }     
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Bill - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
         }
    }//END insertBill
    
    private void insertCharge(List<DM_Charge__c> dm_charge, Id parentId){
        loan__Charge__c charge;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Charge__c> chargeList = new List<loan__Charge__c>();
        if(!dm_charge.isEmpty()){
            for(DM_Charge__c dmCharge : dm_charge){
               charge = dmHandler.DM_StaticFieldMapping_charge(dmCharge,parentId);
               System.debug('charge '+charge);
                if(charge<>null)
                    chargeList.add(charge);
            }    
            try{
                if(!chargeList.isEmpty()){
                    insert chargeList;
                }     
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Charge - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
         }//END if(!dm_charge.isEmpty()){
    }//END insertCharge
    
    private void insertAPS(List<DM_Automated_Payment_Setup__c> dm_APS, Id parentId){
        loan__Automated_Payment_Setup__c APS;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Automated_Payment_Setup__c> APSList = new List<loan__Automated_Payment_Setup__c>();
        if(!dm_APS.isEmpty()){
            for(DM_Automated_Payment_Setup__c dmAps : dm_APS){
               APS = dmHandler.DM_StaticFieldMapping_aps(dmAps,parentId);
                system.debug('APS'+aps);
                if(APS<>null)
                    APSList.add(APS);
            }    
            try{
                if(!APSList.isEmpty()){
                    //Create SavePoint
                    system.debug('APS BI');
                   	insert APSList;
                    system.debug('APS AI');
                }     
            }catch(Exception ex){
               errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - APS - '+ ex.getMessage(), DM_Invalid_Data__c=True, migration_status__c='Failed'));
                Database.rollback(sp);
            }//END Catch   
         }
    }//END insertAPS
    
    private void insertRepaySchedule(List<DM_Repayment_Schedule__c> dm_RepaySch, Id parentId){
        loan__Repayment_Schedule__c repaySch;
        DM_MigrationHandler dmHandler = new DM_MigrationHandler();
        List<loan__Repayment_Schedule__c> repaySchList = new List<loan__Repayment_Schedule__c>();
        if(!dm_RepaySch.isEmpty()){
            for(DM_Repayment_Schedule__c dmRepaySch : dm_RepaySch){
               repaySch = dmHandler.DM_StaticFieldMapping_RepaySCH(dmRepaySch,parentId);
                system.debug('rePaySch'+repaySch);
                if(repaySch<>null)
                    repaySchList.add(repaySch);
            }    
            try{
                if(!repaySchList.isEmpty()){
                    //Create SavePoint
                    insert repaySchList;
                }     
            }catch(Exception ex){
              errorUpdate.add(new DM_Loan_Account__c(Id=contractId, DM_Error__c= 'Exception Thrown - Repayment Schedule - '+ ex.getMessage(), DM_Invalid_Data__c=True));
              Database.rollback(sp);
            }//END Catch   
         }
    }//END insertAPS
}//END DM_Data_Creation