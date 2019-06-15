# Powershell Scripts

<img src="https://raw.githubusercontent.com/jxmoore/powershellScripts/master/img/logo2.png" align="Center"
     title="PowerShell">


This is a collection of my many powershell scripts, functions, one liners etc... that i have used at some point through out my carrer. These were written for various reasons - some were used in CI/CD pipelines, written to automate some of the more boring tasks, for one off unique cases where manual intervention in the GUI would have taken too long. etc... Because of this these scripts are, well, _all over the place_. Some of themare quite old, some are new etc... Please tread the waters carefully. However, having said that, i'm going to host these in this repo for a few reasons: 

* Its FOSS! 
* I constantly see questions regarding powershell usage asked on forums and reddit (**/r/powershell**) and i feel the answers are riddeled in one or more of these scripts. It would be easier to point someone here in the future than scrouring my machines for an example or making one from scratch.
* _Maybe_ it can help some passer by who is hunting google for a specific Powershell example.
* Storing the (now 500+, i know im a horader) ps1's locally is foolish. 


<hr>

### Script formatting
Before diving in it should be said i likely dont write my scripts the same way you do. I think its a fair assumption so for the sake of clarity some tidbits about how i generally structure my powershell scripts, loops and other odds and ends.

1. I favor the pipe at all times, particurally in loops. The `%' is an alias for `Foreach()` and when used the `$_` is the current object in the loop itteration/pipe. So in the below the two are essentially one in the same : 
   ```Powershell
    get-aduser -filter * -properties * | % { $user = $_.samaccountname}
   ```
   ```Powershell
    Foreach($AdUser in $(get-aduser -filter * -properties *)){
        $adUser = $user.Samaccountname
    }
   ```
2. Similarly i prefer to pipe commands to `where` using the alias `?` as well. This looks like :
   ```Powershell
   get-aduser -filter * | select -ExpandProperty samaccountname | ? { $_ -notmatch 'powerhouse'}
   ```  
3. I prefer to use camelCase for variables. For example in example one its `$adUser` rather than `$AdUser`. This is likely due to my time with C# but i think its good to follow some sort of practice, be that camel, snake, pascal etc... 
4. On the subject of C# traits, i also like to use a trailing `;`. For example: 
   ```powershell
   # With semi colon
   write-host "Hello World!";
   # Without 
   write-host "Bye"
   ```
   If for whatever reason it bothers you, then by all means remove it. It will have no impact on the script unless the commands are on one line.
5. You will see some CI/CD specific commands or references from time to time. That may be something like `%TEAMCITY.BULD...%` or `write-highlight "..."`. This is because some of the scripts were written for a CI/CD pipeline. If they are within the script i have likely (_or will try to_) include comments as to what they are and where they come from.

#### I see errors!
Please put in a pull request or ping me and let me know, as i said, the state of these is all over the place. I have tried to correct the obvious issues as i have moved them over but Im bound to miss something at some point.

### Repo Structure
The files are broken apart by their _use case and target_ to some regard. That is to say everything revolving around `Azure` will live within the `Azure` folder, everything that deals with AD will wind up in the `ActiveDirectory` folder and so on.



