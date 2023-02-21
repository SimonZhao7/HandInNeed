String verifyOpportunityEmail(Uri dynamicLink) => """
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;700&display=swap');
  </style>
  <body style='margin: 0; font-family: Montserrat, Google Sans, sans-serif;'>
    <div class='wrapper'>
      <div class='content' style='width: 100%; margin: auto; background: white; border-radius: 10px;'>
        <div class='banner' style='background: #1A75FF; padding: 10px 25px; color: white;'>
          <h1><span style='font-size: 40;'>🤝 </span>HandInNeed</h1>
        </div>
        <div class='content-body' style='background: #0050C7; color: white; padding: 25px;'>
          <h2>Your organization has been mentioned!<span style='font-size: 40;'> 👏</span></h2>
          <br/>
          <div class="text-box" style='background-color: white; color: black; padding: 40px; border-radius: 10px;'>
            <p>A user of our volunteer opportunity sharing app has decided to <b>share information of your upcoming opportunity</b>.</p>
            <p>
            In order to verify and manage attendees that register for this opportunity from our app, please install our app and sign up with this email. Next, verify this opportuity by going to the "Your Jobs" section and the "Your Hostings" tab on the top. Find the correct opportunity and press verify to complete the verification process.
            </p>
            <p>
              <b>If you prefer to use a different email for the account</b>, please provide your desired email by clicking the button below.
            </p>
            <a href="$dynamicLink">
              <button class='link-btn' style='background: #1573FF; color: white; border: 0; width: 200px; height: 50px; border-radius: 5px; font-size: 14px; margin: 30px 0; font-family: Montserrat, Google Sans, sans-serif;'>Transfer Opportunity</button>
            </a>
            <p>If you didn't organize an event, please disregard this email.</p>
            <br/>
            <p>
              Happy Volunteering,
            </p>
            <b style='font-size: 16;'>The HandInNeed Team</b>
          </div>
        </div>
      </div>
    </div>
  </body>
""";