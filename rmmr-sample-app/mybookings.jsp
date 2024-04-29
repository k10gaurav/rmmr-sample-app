<%--
  ~ Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
  ~
  ~ WSO2 Inc. licenses this file to you under the Apache License,
  ~ Version 2.0 (the "License"); you may not use this file except
  ~ in compliance with the License.
  ~ You may obtain a copy of the License at
  ~
  ~ http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing,
  ~ software distributed under the License is distributed on an
  ~ "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  ~ KIND, either express or implied.  See the License for the
  ~ specific language governing permissions and limitations
  ~ under the License.
  --%>

<%@ page import="io.asgardeo.java.oidc.sdk.SSOAgentConstants" %>
<%@ page import="io.asgardeo.java.oidc.sdk.bean.SessionContext" %>
<%@ page import="io.asgardeo.java.oidc.sdk.bean.User" %>
<%@ page import="io.asgardeo.java.oidc.sdk.config.model.OIDCAgentConfig" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="net.minidev.json.JSONObject" %>
<%@ page import="com.nimbusds.jwt.SignedJWT" %>

<%
    final HttpSession currentSession = request.getSession(false);
    final SessionContext sessionContext = (SessionContext)
            currentSession.getAttribute(SSOAgentConstants.SESSION_CONTEXT);
    final String idToken = sessionContext.getIdToken();

    String scopes = "";

    ServletContext servletContext = getServletContext();
    if (servletContext.getAttribute(SSOAgentConstants.CONFIG_BEAN_NAME) != null) {
        OIDCAgentConfig oidcAgentConfig = (OIDCAgentConfig) servletContext.getAttribute(SSOAgentConstants.CONFIG_BEAN_NAME);
        scopes = oidcAgentConfig.getScope().toString();
    }

    SignedJWT signedJWTIdToken = SignedJWT.parse(idToken);
    String payload = signedJWTIdToken.getJWTClaimsSet().toString();
    String header = signedJWTIdToken.getHeader().toString();

    String name = null;
    Map<String, Object> customClaimValueMap = new HashMap<>();

    if (idToken != null) {
        final User user = sessionContext.getUser();
        customClaimValueMap = user.getAttributes();
        name = user.getSubject();
    }
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>Home | RMMR Application</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="theme.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>

    <div class="ui two column centered grid">
      <div class="column center aligned">
            
        <img src="https://cdn2.iconfinder.com/data/icons/us-election-2020/60/130-candidate-meeting-ovation-512.png" class="logo-image" style="width:75px;margin-top:20px !important">
        <h2 style="color: #fff;background-color: darkcyan;padding:20px;">Reserve My Meeting Room</h2>
    </div>
        
        <h3>
            <strong>User ID :</strong> <span id="useremail"></span>
        </h3>
        <div class="container" style="margin-top: 10px;">
           
            <div class="header-main" style="background: #205c8d;padding:10px;border-radius: 10px 10px 0 0;color: #fff;">
                <h3> My Bookings</h3>
                <a href="home.jsp" style="float: left;margin-top: 20px;text-decoration: none;padding:10px;background-color: #205c8d;color: #fff;">Home</a>
            </div>
            <form action="logout" method="GET">
                <div class="element-padding" style="float: right;">
                    <button class="btn primary" type="submit" style="background-color: #037411;">Logout</button>
                </div>
            </form>
            <div class="content" style="min-height: 275px;">
              <div id="inner-content" style="margin-top:20px;">
                <div id="roomsDiv">Loading....</div> 
               </div> 
            </div>
        </div>
        <div style="margin-top: 50px;"> RMMR | 2024 | All Rights Reserved</div>
    </div>
    <script src="https://unpkg.com/json-formatter-js@latest/dist/json-formatter.umd.js"></script>

    <script>
        var payload = '<%=payload %>';
        var header = '<%=header %>';
        var idToken = '<%=idToken %>';
        var name = '<%=name%>';
        var scope = '<%=scopes%>';
        const scopeList = scope.split(" ");
        let responses = {
            "allowedScopes" : scopeList,
            "username" : name
        }
        var payloadObject = JSON.parse(payload);
        var headerObject = JSON.parse(header);
        var responseObject = JSON.parse(JSON.stringify(responses));
       
        var email=payloadObject.username;
       
        console.log(payloadObject.username);
         const idTokenSplit = idToken.split(".");
        document.getElementById("useremail").innerHTML = email;
    </script>
    <script>
        $(document).ready(function() {
          // Define your cURL request parameters
          var tokenUrl = 'https://sts.choreo.dev/oauth2/token?grant_type=client_credentials';
          var clientId = 'GgDUUPpozmKsFnhTezQDone0rc0a';
          var clientSecret = 'Rf29fNt8rTzuys_7shGmb0MDEaoa';
          var apiEndpoint = 'https://b1771805-d0ae-4ce9-b5c8-2a10cd888fae-prod.e1-us-cdp-2.choreoapis.dev/xnkj/rmmrservices/endpoint-8080-5c6/v1.0/bookings_by_id/'+email;

        
          // Encode the client ID and client secret as Base64
          var authHeader = 'Basic ' + btoa(clientId + ':' + clientSecret);
        
          // Make AJAX request to obtain access token
          $.ajax({
                type: 'POST',
                url: tokenUrl,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': authHeader
                },
    success: function(response) {
        var attributesDiv = $('#attributesDiv');
        // Print the access token attribute inside the div
      // attributesDiv.html('<p>Access Token: ' + response.access_token + '</p>');

        // Make second AJAX request using the access token
        var accessToken = response.access_token;
        $.ajax({
          type: 'GET',
          url: apiEndpoint,
          headers: {
            'Authorization': 'Bearer ' + accessToken
          },
          success: function(roomsResponse) {
            var roomsDiv = $('#roomsDiv');
            // Generate HTML for the table
            var tableHTML = '<table border="1">';
            tableHTML += '<tr><th>Room ID</th><th>Attendees Count</th><th>Reason</th><th>Start Time</th><th>End Time</th><th>Resources</th><th>Booking Status</th></tr>';
            // Iterate over the rooms data and add rows to the table
            roomsResponse.forEach(function(room) {
              if(room.booking_status=="not_booked"){
                booking_status="Initiated";
              }
              else{
                booking_status=room.booking_status;
              }
              tableHTML += '<tr>';
              tableHTML += '<td>' + room.room_id + '</td>';
              tableHTML += '<td>' + room.attendees + '</td>';
              tableHTML += '<td>' + room.reason + '</td>';
              tableHTML += '<td>' + room.start_time + '</td>';
              tableHTML += '<td>' + room.end_time + '</td>';
              tableHTML += '<td>' + room.resources + '</td>';
              tableHTML += '<td>' + booking_status + '</td>';
              tableHTML += '</tr>';
            });
            tableHTML += '</table>';
            // Add the table to the roomsDiv
            roomsDiv.html(tableHTML);
          },
          error: function(xhr, status, error) {
            console.error('Error:', error);
          }
        });
    },
    error: function(xhr, status, error) {
      console.error('Error:', error);
    }
  });
});
        </script>
</body>
</html>
