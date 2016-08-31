# Pocket Casts Ubuntu Touch webapp

This webapp is based on ogra's alternate-webapp-container:

    bzr branch lp:~ogra/junk/alternate-webapp-container

This is a new approach using an alternate webapp container that
does not use a toolbar at the top but instead provides a bottom
menu with navigation objects. 

## TODO

  * Try and make playback controls available via radial navigation.
  * Add radial navigation for:
    * https://play.pocketcasts.com/web#/podcasts/discover
    * https://play.pocketcasts.com/web#/podcasts/new_releases
    * https://play.pocketcasts.com/web#/podcasts/in_progress
    * https://play.pocketcasts.com/web#/podcasts/starred

## Changes

### 1.0

  * Initial release.

# Development

## Building

Edit the value of `applicationName` at the top of `qml/Main.qml` to match
your application name to work around <https://launchpad.net/bugs/1435778>

Edit `config.js` to add `webappName`, `webappUrl` and `webappUrlPattern`
similar to how you would use them as commandline options to webapp-container.

Optionally you can set the `webappUA` variable in `config.js` to override
the User Agent string.

Edit the `.desktop` and `manifest.json` to your liking.

Replace icon.png with your own icon that is 128x128.

Now run:

    click build .

This will create a `.click` package with you webapp.

## Installing

Push the click to your device via adb, then:

    adb shell pkcon install-local --allow-untrusted /path/to/click

You will see a bunch of progress bars ... once they are done,
pull down the app scope to refresh it and find your new app in there.

## Publishing

Publish the generated click package at https://myapps.developer.ubuntu.com/dev/click-apps/

# License

touch-app-pocketcasts is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

touch-app-pocketcasts is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with touch-app-lastpass. If not, see <http://www.gnu.org/licenses/>.
