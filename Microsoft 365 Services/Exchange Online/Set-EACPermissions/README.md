# commonEACTasks: A powershell script to help configure common Exchange Admin Center Tasks

<h2 align="left"> <a href="https://github.com/zhudso/mailboxPermissions/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/zhudso/mailboxPermissions"></a> <a href="https://github.com/zhudso/mailboxPermissions/network"><img alt="GitHub forks" src="https://img.shields.io/github/forks/zhudso/mailboxPermissions"></a> <a href="https://github.com/zhudso/mailboxPermissions/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/zhudso/mailboxPermissions"></a> <a href="https://github.com/zhudso/mailboxPermissions"><img alt="GitHub license" src="https://img.shields.io/github/license/zhudso/mailboxPermissions"></a> </h2>

### Features:
* An easier way to configure your common day to day tasks in exchange
* Select your desired configuration by entering a number from a list of tasks that are shown
* Opens Powershell as Administrator
* Connects to Exchange Online
* Allows the session to stay open if you have more tasks to perform
* Allows to add/remove multiple users
* Will remove the session after script completes

### Known limitations:
* Not friendly on going back on your configuration task if you've selected the wrong option
    * There are confirmation questions if a user profile is found or not but not to re-select a configuration tasks.
        * Work around: Hit enter until you're able to get the "Would you like to end the session? (Y/N)" prompt and enter N or No to re-run the script
* Retreiving information
    * This script was created for simple configuration purposes with the idea in mind that we do not need to retreive information.