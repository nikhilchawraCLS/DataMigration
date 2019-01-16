@isTest
public class Test_DM_MigrationJob {
    @testSetup
    static void testData(){
        loan__Org_Parameters__c orgParam = new loan__Org_Parameters__c();
        orgParam.loan__Disable_Triggers__c=true;
        orgParam.loan__Digits_After_Decimals__c=2;
        orgParam.loan__Rounding_Mode__c='Nearest';
        insert orgParam;
        
        loan__Trigger_Parameters__c triggerParam = new loan__Trigger_Parameters__c();
        triggerParam.loan__Disable_Loan_Account_Trigger__c=true;
        insert triggerParam;
        
        loan.TestHelper.createSeedDataForTesting();
        loan.TestHelper.setupApprovalProcessForTxn();  
        Account a2 = loan.TestHelper2.createInvestor('Bull', 1000); 
        loan.CustomSettingsUtil.getNS();
        //Create Borrower 
        Account b1 = loan.TestHelper2.createBorrower('ShoeString'); 
        loan.TestHelper.systemDate = Date.today(); 
        Id rtId = Schema.SObjectType.loan__Office_Name__c.getRecordTypeInfosByName().get('Root Branch').getRecordTypeId();
        Id prodRTId = Schema.SObjectType.loan__Loan_Product__c.getRecordTypeInfosByName().get('Loan Product Record Type').getRecordTypeId();

        loan__Currency__c curr = loan.TestHelper.createCurrency();
        loan__office_Type__c testBranchType = new loan__Office_Type__c(Name='Data Migration',
                                                        loan__Office_Type_Short_Code__c='TestSC' );
        insert testBranchType;
                                                               
        loan__MF_Account__c a1 = loan.TestHelper.createMFAccount('TestAccountForOffice', '10000 - ASSETS');
    
        loan__Branch_Location__c testLoc = new loan__Branch_Location__c(Name='Data Migration',
                                            loan__Address_Line_1__c = 'Add1',
                                            loan__Address_Line_2__c = 'Add2',
                                            loan__State__c = 'MH',
                                            loan__Phone__C = '32323232',
                                            loan__Zip_code__c = 33333
                                            );
        insert testLoc;
        
        loan__Office_Name__c dummyOffice = new loan__Office_Name__c(Name='Data Migration',
                                                    loan__Office_Location__c = testLoc.ID,
                                                    loan__Office_Short_Name__c = 'XXXCSN',
                                                    loan__Cash_Account__c = a1.Id,
                                                    loan__Check_Account__c = a1.Id,
                                                    loan__Bank_Account_Checks__c = a1.Id,
                                                    loan__Inward_Check_Clearance_Account__c = a1.Id,
                                                    loan__Outward_Check_Clearance_Account__c= a1.Id,
                                                    loan__Profit_and_Loss_Account__c = a1.Id,
                                                    loan__Loan_Schedule_tied_to_Meeting_Schedule__c = false,
                                                    loan__Mark_Suspended_After_Days__c = 180,
                                                    loan__State__c = 'Active',
                                                    loan__Write_Off_Suggestion_Days__c = 90,
                                                    loan__Office_Type__c = testBranchType.ID,
                                                    loan__Days_in_advance_to_create_Collection_Rep__c=1,
                                                    loan__Current_System_Date__c = Date.Today().addDays(-30),
                                                    RecordTypeId = rtId,
                                                    loan__Is_Branch__c=true);
        insert dummyOffice;
                
        loan__MF_Account__c dummyIncAccount = loan.TestHelper.createMFAccount('XXXIncAccountForTest', '30000 - INCOME');
        loan__MF_Account__c dummyAccount = loan.TestHelper.createMFAccount('XXXAccountForTest', '10000 - ASSETS');
        loan__Fee__c dummyFee = loan.TestHelper.createFee(curr, dummyIncAccount, dummyAccount); 
        loan__Fee_Set__c dummyFeeSet = loan.TestHelper.createFeeSet(); 
        loan__Fee_Junction__c dummyFeeJunction = loan.TestHelper.createFeeJunction(dummyFee, dummyFeeSet);
        List<loan__Loan_Product__c> loanProductList = new List<loan__Loan_Product__c>();
        loan__Loan_Product__c simpleLP = DM_TestHelper.createLoanProduct('Simple Loan',dummyOffice, 
                                              dummyAccount, curr, dummyFeeSet, 'Loan'); 
        loanProductList.add(simpleLP);
        
        loan__Loan_Product__c difficultLP = DM_TestHelper.createLoanProduct('Difficult Loan',dummyOffice, 
                                              dummyAccount, curr, dummyFeeSet, 'Loan');
        loanProductList.add(difficultLP);
        
        loan__Loan_Product__c errorLp = DM_TestHelper.createLoanProduct('Simple Loan',dummyOffice, 
                                              dummyAccount, curr, dummyFeeSet, 'Loan');
        loanProductList.add(errorLp);
        
        insert loanProductList;
                     
        loan__Payment_Mode__c pMode = new loan__Payment_Mode__c(name='Cash');
       // insert pMode;
        
        loan__Bank_Account__c bankAccount = new loan__Bank_Account__c(loan__Bank_Account_Number__c = '12', 
                                                 loan__Bank_Name__c = 'Some Bank', 
                                                 loan__Routing_Number__c = '99999999', 
                                                 loan__Account_Type__c = 'Savings', 
                                                 loan__Account_Usage__c = 'Borrower/Investor Account', 
                                                 loan__Account__c = b1.id);
        insert bankAccount;
        
        List<DM_Loan_Account__c> dmLoanList = new List<DM_Loan_Account__c>();
        DM_Loan_Account__c dmloan = DM_TestHelper.createDMLOC(simpleLP,0.0,b1,dummyFeeSet,dummyOffice,5,'Declining Balance');
        dmLoanList.add(dmloan);
        
        DM_Loan_Account__c dmloan2 = DM_TestHelper.createDMLOC(difficultLP,0.0,b1,dummyFeeSet,dummyOffice,5,'Declining Balance');
        dmLoanList.add(dmloan2);
        
        DM_Loan_Account__c dmloan3 = DM_TestHelper.createDMLOC(errorLp,0.0,b1,dummyFeeSet,dummyOffice,5,'Error');
        dmLoanList.add(dmloan3);
        insert dmLoanList;
        
        DM_Loan_Disbursal_Transaction__c ldt =  DM_TestHelper.fundLoan(dmLoan, Date.Today(), pmode,bankAccount);
        insert ldt;
                                                        
        DM_Bill__c bill =  DM_TestHelper.createUnpaidDue(dmLoan, 6500.00);
        insert bill;
        
        DM_Repayment_Schedule_Summary__c dm_RSS = DM_TestHelper.CreateRSSData(dmLoan, 600.00);
        insert dm_RSS;
        
        DM_Charge__c charge =  DM_TestHelper.createUnpaidCharge(dmLoan, dummyFee, 100.00 );
        insert charge;
        
        DM_Repayment_Schedule__c AmzSchedule = DM_TestHelper.CreateAmzScheduleData(dmLoan, 1000.00);
        insert AmzSchedule;
        
        DM_Automated_Payment_Setup__c aps =  DM_TestHelper.createAutomatedPaymentSetup('DO it later', '', bankAccount,
                                                         dmLoan, '', pMode, Date.Today(),1);
        insert aps;
        
        DM_Loan_Payment_Transaction__c lpt = DM_TestHelper.createLoanPayment(dmLoan.Id, 10000.00,Date.today(),aPS, pMode, null);
        insert lpt;
    }//END testData
    
    @isTest
    static void JobForSimpleLoanAndStrategyZero_IsTest(){ 
        //List<DM_Loan_Account__c> dmList = [select id from DM_Loan_Account__c];
        User u = [Select Id from User limit 1];
        system.runAs(u){
            Test.startTest();
            DM_MigrationJob dm = new Dm_MigrationJob('Simple Loan');
            Database.executeBatch(dm,1);
            Test.stopTest();
            List<loan__Loan_Account__c> loanAcc = [select Id,custesting__c from loan__Loan_Account__c];
            System.assert(!loanAcc.isEmpty());
            system.assert(loanAcc[0].custesting__c<>null);
            List<DM_Loan_Account__c> DMAcc = [select Id,migration_Status__c,DM_Error__c,DM_Is_Migrated__c,Migrated_CL_Contract__c from DM_Loan_Account__c where Batch_Type__c='Simple Loan'];
            system.assert(DMAcc[0].migration_Status__c=='Success');
            system.assert(DMAcc[0].DM_Is_Migrated__c);
            system.assert(DMAcc[0].Migrated_CL_Contract__c<>null);
        }//END system.runAs(u)
    }//END RunJobTemp_IsTest 
    
    @isTest
    static void JobForDifficultLoanAndStrategy1000_IsTest(){ 
        User u = [Select Id from User limit 1];
        system.runAs(u){
            Test.startTest();
            DM_MigrationJob dm = new Dm_MigrationJob('Difficult Loan');
            Database.executeBatch(dm,1);
            Test.stopTest();
            List<loan__Loan_Account__c> loanAcc = [select Id,custesting__c from loan__Loan_Account__c];
            System.assert(!loanAcc.isEmpty());
            List<DM_Loan_Account__c> DMAcc = [select Id,migration_Status__c,DM_Error__c,DM_Is_Migrated__c,Migrated_CL_Contract__c from DM_Loan_Account__c where Batch_Type__c='Difficult Loan'];
            system.assert(DMAcc[0].migration_Status__c=='Success');
            system.assert(DMAcc[0].DM_Is_Migrated__c);
            system.assert(DMAcc[0].Migrated_CL_Contract__c<>null);
        }//END system.runAs(u) 
    }//END RunJobTemp_IsTest 
    
    @isTest
    static void JobForFailedCustomValidation_IsTest(){ 
        List<DM_Loan_Account__c> dmList = [select id from DM_Loan_Account__c];
        User u = [Select Id from User limit 1];
        system.runAs(u){
            Test.startTest();
            DM_MigrationJob dm = new Dm_MigrationJob('Error');
            Database.executeBatch(dm,1);
            Test.stopTest();
            List<loan__Loan_Account__c> loanAcc = [select Id,custesting__c from loan__Loan_Account__c];
            System.assert(loanAcc.isEmpty());
            List<DM_Loan_Account__c> DMAcc = [select Id,migration_Status__c,DM_Error__c,DM_Is_Migrated__c,Migrated_CL_Contract__c from DM_Loan_Account__c where Batch_Type__c='Error'];
			system.assert(DMAcc[0].migration_Status__c=='Failed');
            system.assert(!DMAcc[0].DM_Is_Migrated__c);
            system.assert(DMAcc[0].Migrated_CL_Contract__c==null);
        }//END system.runAs(u)
    }//END RunJobTemp_IsTest
}//END Test_DM_MigrationJob