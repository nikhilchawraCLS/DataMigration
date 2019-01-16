Global with sharing class DM_ValidationWrapper 
{ 
    public Id id;
    public Boolean success = false ;
    public String errorMessage;
    
    Global DM_ValidationWrapper(){}
    
    Global DM_ValidationWrapper(Id id, Boolean success, String errorMessage){
        this.id= id; 
        this.success=success;
        this.errorMessage=errorMessage;
    }//END Global DM_ValidationWrapper
}//END DM_ValidationWrapper