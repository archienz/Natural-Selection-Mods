Helper (v1.0 - 21.06.06)
By: mE @ PsiX.org

Description:
  This plugin provides a consistent help interface for all plugins that alter
  the gameplay and need to inform the client about this. Clients simply have to
  type /help in chat mode to open up a menu which lists all plugins detected.
  It also allows plugins to "advertise", ie showing up a message on round start
  to inform clients that the gameplay has been changed.

Installation:
  Place the help.inc into the "scripting/include" folder and then
  install this plugin just like any other. Plugins supporting "Helper" should
  have a define named "HELPER" within their configuration section which has to
  be set to "1" and recompiled in order to work.
  
Advantages/Disadvantages:
  + Consistent help interface for game-altering plugins
  + Stops spamming client's screen
  + Clients do only have to remember one command (say /help)
  + One global place for clients to be informed about changes, so they can't
      claim they don't know how to use certain features
  + Requires less code than normal helping and advertising
  + Backwards compatability if plugins don't incorporate the new features
  + You can select just your desired plugins (if they support it)
  - Requires an additional .inc which has to be placed in your include folder
  - Requires plugin authors to manually implement the new features
  
Developers:
  Take a look at the demo_helper.sma to see some of this plugin's features or
  read through the .inc
  Feel free to implement the new system as it makes things easier compared to
  normal helping and advertising. Also it's nicer to have a consistent interface
  and server ops and clients will appreciate this.
