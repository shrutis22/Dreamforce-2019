/**
 * Apex Controller for the "Dreamforce2019"
 * VF Page.
 *
 * @author      Shruti Sridharan
 * @since       17 Oct 2019
 * @revisions   NIL 
 */
public class Dreamforce2019Controller {
    private final static String ERR_MSG     = System.label.ERR_MSG;
    private final static String NO_SESSIONS = System.label.NO_SESSIONS;
    
    public class Response {
        public Boolean status;
        public String message;
        public String data;
        
        public Response( Boolean status, String message, String data ) {
            this.status  = status;
            this.message = message;
            this.data    = data;
        }
    }
    
    public static String SESSIONS_ENDPOINT { 
        get {
            Dreamforce_Setting__mdt dreamforceSetting = [
                SELECT  Sessions_Endpoint__c
                FROM    Dreamforce_Setting__mdt
                WHERE   DeveloperName = 'Dreamforce_2019'
            ];
            
            return dreamforceSetting.Sessions_Endpoint__c;
        }
    }
    
    /**
     * Downloads Dreamforce 2019 sessions from
     * the Official Website offset by the "date"
     * and "last retrieved session".
     *
     * @param       since           Date on the last retrieved
     *                              session.
     * @param       lastSessionId   Id of the last retrieved session.
     * 
     * @return      {Response}      All the downloaded sessions
     */
    @RemoteAction
    public static Response downloadSessions( String since, String lastSessionId ) {
        String endpoint = SESSIONS_ENDPOINT;
        
        if( since != 'N/A' ) {
            endpoint += '&since=' + since.replace( '+0000', 'Z' );
        }
        else {
            endpoint += '&since=1970-01-01T00:00:00.000Z';
        }
        
        if( lastSessionId != 'N/A' ) {
            endpoint += '&lastSessionId=' + lastSessionId;
        }
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod( 'GET' );
        httpReq.setEndpoint( endpoint );
        httpReq.setHeader( 'Content-Type', 'application/json' );
        httpReq.setTimeout( 120000 );
        
        try {
            HttpResponse httpResp = new Http().send( httpReq );
            
            if( httpResp.getStatusCode() == 200 ) {
                return new Response( TRUE, NULL, httpResp.getBody() );
            }
            else {
                return new Response( FALSE, ERR_MSG + httpResp.getBody(), NULL );
            }
        }
        catch( Exception ex ) {
            return new Response( FALSE, ERR_MSG + ex.getMessage(), NULL );
        }
    }
    
    /**
     * Save all the downloaded sessions in the
     * Custom Object - Session__c.
     *
     * @param       sessions        List of the downloaded sessions
     *
     * @return      {Response}      Result of the save operation
     */
    @RemoteAction
    public static Response saveSessions( List<Session__c> sessions ) {
        if( 
            sessions!= NULL     && 
            !sessions.isEmpty() 
        ) {
            try {
                UPSERT sessions Dreamforce_Session_Id__c;
                
                return new Response( TRUE, NULL, NULL );
            }
            catch( Exception ex ) {
                return new Response( FALSE, ERR_MSG + ex.getMessage(), NULL );
            }
        }
        
        return new Response( FALSE, NO_SESSIONS, NULL );
    }
}