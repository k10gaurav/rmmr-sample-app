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
                <h3> New Meeting Room Booking</h3>
                <a href="home.jsp" style="float: left;margin-top: 20px;text-decoration: none;padding:10px;background-color: #205c8d;color: #fff;">Home</a>
            </div>
            <form action="logout" method="GET">
                <div class="element-padding" style="float: right;">
                    <button class="btn primary" type="submit" style="background-color: #037411;">Logout</button>
                </div>
            </form>
            <div class="content" style="min-height: 275px;">
              <div id="inner-content" style="margin-top:20px;">
                <h2>Room Booking Form</h2>
                <div id="status" style="background-color: beige;padding: 5px;  margin: 10px;font-weight: bold;"></div>
                  <form id="bookingForm">
                    <label for="roomId">Room ID:</label><br>
                    <input type="text" id="roomId" name="roomId"><br><br>

                    <label for="attendees">Attendees:</label><br>
                    <input type="number" id="attendees" name="attendees"><br><br>

                    <label for="reason">Reason:</label><br>
                    <textarea id="reason" name="reason" rows="4" cols="50"></textarea><br><br>

                    <label for="bookedBy">Booked By:</label><br>
                    <input type="text" id="bookedBy" name="bookedBy" style="background-color: #d0d0d0;" readonly><br><br>

                    <label for="startTime">Start Time:</label><br>
                    <input type="datetime-local" id="startTime" name="startTime"><br><br>

                    <label for="endTime">End Time:</label><br>
                    <input type="datetime-local" id="endTime" name="endTime"><br><br>

                    <label for="resources">Resources:</label><br>
                    <input type="text" id="resources" name="resources"><br><br>

                    <input type="submit" class="btn primary" style="background-color: #037411;" value="Submit">
                    
                  </form>
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
        document.getElementById("bookedBy").value = email;
    </script>
    <script>
        $(document).ready(function() {

          var tokenUrl = 'https://sts.choreo.dev/oauth2/token?grant_type=client_credentials';
          var clientId = 'GgDUUPpozmKsFnhTezQDone0rc0a';
          var clientSecret = 'Rf29fNt8rTzuys_7shGmb0MDEaoa';
          var apiEndpoint = 'https://b1771805-d0ae-4ce9-b5c8-2a10cd888fae-prod.e1-us-cdp-2.choreoapis.dev/xnkj/rmmrservices/endpoint-8080-5c6/v1.0/book_room';
          // Encode the client ID and client secret as Base64
          var authHeader = 'Basic ' + btoa(clientId + ':' + clientSecret);
        
          $('#bookingForm').submit(function(event) {
          event.preventDefault(); // Prevent form submission
          
          document.getElementById("status").innerHTML = "RMMR:Booking in Progress....."

        var formData = {
          room_id: parseInt($('#roomId').val()),
          attendees: parseInt($('#attendees').val()),
          reason: $('#reason').val(),
          booked_by: $('#bookedBy').val(),
          start_time: $('#startTime').val(),
          end_time: $('#endTime').val(),
          resources: $('#resources').val()
        };

        $.ajax({
          type: 'POST',
            url: tokenUrl,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': authHeader
            },
          success: function(response) {
            
            var accessToken = response.access_token;
            $.ajax({
            type: 'POST',
            url: apiEndpoint,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ' + accessToken
            },
            data: JSON.stringify(formData),
            success: function(roomsResponse) {
              alert("RMMR: Meeting room booked successfully!")
              document.getElementById("status").innerHTML = "RMMR: Meeting room booked successfully"

              console.log('Success:', response);
              // Clear form fields on successful submission
              $('#bookingForm')[0].reset();

            },
            error: function(xhr, status, error) {
              console.error('Error:', error);
              document.getElementById("status").innerHTML=error;
            }
          });
          },
          error: function(xhr, status, error) {
            console.error('Error:', error);
            document.getElementById("status").innerHTML=error;
          }
        });
      });
        });
        </script>
</body>
</html>
