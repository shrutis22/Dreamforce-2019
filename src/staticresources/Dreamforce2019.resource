/**
 * JS Resource for the
 * Dreamforce 2019 App.
 *
 * @author      Shruti Sridharan
 * @since       17 Oct 2019
 * @revisions   NIL
 */
var Dreamforce2019 = {
    constants : {
        messages : {
            
        }
    },
    variables : {
        
    },
    helpers : {
        /**
         * [Message Logger]
         * 
         * @param  {[String]} msg [Message to be logged]
         */
        log : function( msg ) {
            var $ele = $( "#txtDloadLog" );
            
            var log = $ele.val();
            
            msg = '[' + new Date().toString() + ']' + ': ' + msg;
            
            if( log === "" ) {
                log = msg;
            }
            else {
                log = log + "\n\n" + msg;
            }
            
            $ele.val( log ).scrollTop( $ele.prop( "scrollHeight" ) );
        },
        /**
         * [Enable/Disable the buttons and 
         * progress indicator.]
         * 
         * @param  {Boolean} isEnabled [Flag]
         */
        enableDownload : function( isEnabled ) {
            var $btn    = $( "#btnDownload" );
            var $status = $( "#divStatus" );
            
            $btn.attr( "disabled", !isEnabled );
            
            isEnabled ? $status.hide() : $status.show();
        }
    },
    actions : {
        /**
         * [Download the session from the DF
         * website via an HttpRequest initiated
         * via Apex Remote Action]
         * 
         * @param  {[String]} since         [Date on the last retrieved]
         * @param  {[String]} lastSessionId [Id of the last retrieved session]
         */
        getSessions : function( since, lastSessionId ) {
            var messages = Dreamforce2019.constants.messages;
            
            Dreamforce2019.helpers.enableDownload( false );
            
            try {
                var allSessions = [];
                
                Dreamforce2019Controller.downloadSessions(
                    since,
                    lastSessionId,
                    function( result, event ) {
                        if( event.status && result.status ) {
                            var speakerNames        = null;
                            var downloadedSessions  = JSON.parse( result.data );
                            
                            if( downloadedSessions.length > 0 ) {
                                downloadedSessions.forEach(
                                    function( dfSession ) {
                                        if( dfSession.Active__c && dfSession.IsVisibleToUsers__c ) {
                                            var allSpeakers = [];
                                            
                                            /**
                                             * Ensure we have speaker information
                                             * available.
                                             */
                                            if( dfSession.Session_Speakers__r !== undefined ) {
                                                if( dfSession.Session_Speakers__r.records !== undefined ) {
                                                    dfSession.Session_Speakers__r.records.forEach(
                                                        function( speaker ) {
                                                            var name;
                                                            if( speaker.EventSpeaker__r &&
                                                                speaker.EventSpeaker__r.FirstName__c
                                                            ) {
                                                                name = speaker.EventSpeaker__r.FirstName__c + " ";
                                                            }
                
                                                            if( speaker.EventSpeaker__r &&
                                                                speaker.EventSpeaker__r.LastName__c
                                                            ) {
                                                                name += speaker.EventSpeaker__r.LastName__c;
                                                            }
                                                            
                                                            if( name !== undefined ) {
                                                                allSpeakers.push( name.trim() );
                                                            }
                                                        }
                                                    );
                                                }
                                            }
                                            
                                            if( allSpeakers.length > 0 ) {
                                                speakerNames = allSpeakers.join( "," );
                                            }
                                            
                                            var newSession = {};
        
                                            if( dfSession.Name                  !== undefined ) {
                                                newSession.Name                  = dfSession.Name;
                                            }
        
                                            if( dfSession.Solution__c           !== undefined ) {
                                                newSession.Solution__c           = dfSession.Solution__c;
                                            }
        
                                            if( dfSession.Level__c              !== undefined ) {
                                                newSession.Level__c              = dfSession.Level__c;
                                            }
        
                                            if( dfSession.Product__c            !== undefined ) {
                                                newSession.Product__c            = dfSession.Product__c;
                                            }
        
                                            if( dfSession.Session_Theme__c      !== undefined ) {
                                                newSession.Session_Theme__c      = dfSession.Session_Theme__c;
                                            }
        
                                            if( dfSession.Session_Start_Time__c !== undefined ) {
                                                newSession.Session_Start_Time__c = new Date( dfSession.Session_Start_Time__c ).getTime();
                                            }
        
                                            if( dfSession.Session_End_Time__c   !== undefined ) {
                                                newSession.Session_End_Time__c   = new Date( dfSession.Session_End_Time__c ).getTime();
                                            }
        
                                            if( dfSession.Session_Abstract__c   !== undefined ) {
                                                newSession.Session_Abstract__c   = dfSession.Session_Abstract__c;
                                            }
        
                                            if( speakerNames                    !== null ) {
                                                newSession.Speaker__c            = speakerNames;
                                            }
                                            
                                            if( dfSession.Role__c               !== undefined ) {
                                                newSession.Role__c              = dfSession.Role__c;
                                            }
                                            
                                            if( dfSession.Industry              !== undefined ) {
                                                newSession.Industry__c          = dfSession.Industry;
                                            }
                                            
                                            if( dfSession.RecordType            !== undefined ) {
                                                newSession.Session_Type__c      = dfSession.RecordType.Name;
                                            }
                                            
                                            if( dfSession.Room__r               !== undefined ) {
                                                newSession.Room_Name__c         = dfSession.Room__r.Name;
                                                
                                                if( dfSession.Room__r.Venue__r !== undefined ) {
                                                    newSession.Venue_Name__c    = dfSession.Room__r.Venue__r.Name;
                                                    
                                                    newSession.GoogleMapURL__c  = dfSession.Room__r.Venue__r.GoogleMapURL__c;
                                                }
                                            }
                                            
                                            if( dfSession.Best_Of_Dreamforce__c !== undefined ) {
                                                newSession.Best_Of_Dreamforce__c= dfSession.Best_Of_Dreamforce__c;
                                            }
                                            
                                            if( dfSession.Id                    !== undefined ) {
                                                newSession.Dreamforce_Session_Id__c = dfSession.Id;
                                            }
                                            
                                            allSessions.push( newSession );
                                        }
                                    }
                                );
        
                                var since           = downloadedSessions[downloadedSessions.length - 1].LastModified_AttendeeCritical__c;
                                var lastSessionId   = downloadedSessions[downloadedSessions.length - 1].Id;
                                
                                /**
                                 * Save the sessions to the
                                 * Session Custom Object.
                                 */
                                Dreamforce2019Controller.saveSessions(
                                    allSessions,
                                    function( result, event ) {
                                        if( event.status && result.status ) {
                                            if( downloadedSessions.length > 0 ) {
                                                Dreamforce2019.helpers.log( messages.PROGESS_MSG.replace( "##COUNT##", allSessions.length ) );
            
                                                Dreamforce2019.actions.getSessions( since, lastSessionId );
                                            }
                                        }
                                        else if( !event.status ) {
                                            Dreamforce2019.helpers.log( messages.ERR_MSG + event.message );
                                            
                                            alert( messages.ERR_MSG + event.message );
                                            
                                            Dreamforce2019.helpers.enableDownload( true );
                                        }
                                        else {
                                            Dreamforce2019.helpers.log( result.message );
                                            
                                            alert( result.message );
                                            
                                            Dreamforce2019.helpers.enableDownload( true );
                                        }
                                    },
                                    {
                                        escape : false,
                                        buffer : false,
                                        timeout: 120000
                                    }
                                );
                            }
                            else {
                                Dreamforce2019.helpers.log( messages.COMPLETED_MSG );
                                
                                alert( messages.COMPLETED_MSG );
                                
                                Dreamforce2019.helpers.enableDownload( true );
                            }
                        }
                        else if( !event.status ) {
                            Dreamforce2019.helpers.log( messages.ERR_MSG + event.message );
                            
                            alert( messages.ERR_MSG + event.message );
                            
                            Dreamforce2019.helpers.enableDownload( true );
                        }
                        else {
                            Dreamforce2019.helpers.log( result.message );
                            
                            alert( result.message );
                            
                            Dreamforce2019.helpers.enableDownload( true );
                        }
                    },
                    {
                        escape : false,
                        buffer : false,
                        timeout: 120000
                    }
                );
            }
            catch( error ) {
                Dreamforce2019.helpers.log( messages.ERR_MSG + error );
                
                alert( messages.ERR_MSG + error );
                
                Dreamforce2019.helpers.enableDownload( true );
            }
        }
    },
    handlers : {
        /**
         * [Handler for the "Start Download" button]
         */
        getSessions : function() {
            var messages = Dreamforce2019.constants.messages;
            
            alert( messages.START_MSG );
            
            Dreamforce2019.helpers.log( messages.START_MSG );
            
            Dreamforce2019.actions.getSessions( "N/A", "N/A" );
        }
    },
    init : function() {
        
    }
};
