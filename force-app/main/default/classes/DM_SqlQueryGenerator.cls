public with sharing class DM_SqlQueryGenerator 
{
    public String GetQueryString(String srcObject,String migrationBatchType)
    {
        string query ='';
        string parent='';
        string status='pending';
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = new Map <String, Schema.SObjectField>();
        for(String sObj : srcObject.split(';')){
            fieldMap =schemaMap.get(sObj).getDescribe().fields.getMap();
            String queryFields = Null;
            for(Schema.SObjectField sField :fieldMap.values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                if(queryFields != Null)
                {
                    queryFields = queryFields + ',' + dfield.getname();
                }
                else
                {
                    queryFields = dfield.getname();
                }
            } 
            
            if(sobj !='DM_Loan_Account__c'){
                sobj = sobj.replace('__c','s__r');
                query += '(Select '+queryFields+ ' from '+sobj +'),';
            }
            else{
                system.debug('batch Type '+migrationBatchType);
                query= query.removeEnd(',');
                parent = 'select '+queryFields+','+query+' from '+sobj + ' where Migration_status__c = \'' +status+ '\' '; 
                if(migrationBatchType<>null)
                    parent += ' And Batch_Type__c = \''+migrationBatchType+ '\'';
            }           
        }
        System.debug(parent);
        return parent;
    }
}