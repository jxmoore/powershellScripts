## Post a slack message
## New-SlackNotification -webhook "https://slack..." -userName "alert" -channel "oncall" -title "Server01 is down" `
##                       -body "server01..." -color "red"
function New-SlackNotification{
  param
  (
      [String][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$webhook,
      [String][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$userName,
      [String][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$channel,
      [String][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$title,
      [String][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$body,
      [String][Parameter(Mandatory=$false)]$color="green",
      [String][Parameter(Mandatory=$false)]$icon="https://cdn.iconscout.com/icon/free/png-256/slack-1425877-1205068.png"
  )
 
    $hook_config = @{
        channel = $channel;
        username = $userName;
        icon_url = "$icon";
    };

    $notificationFields = @{
        title = $title;
        value = $body;
        fallback = $body;
        color = $color;
    };

 
    $payload = @{
        channel = $hook_config["channel"];
        username = $hook_config["username"];
        icon_url = $hook_config["icon_url"];
        attachments = @(
            @{
            fallback = $notificationFields["fallback"];
            color = $notificationFields["color"];
            title = $notificationFields["title"];
            title_link = $notificationFields["title_link"];
            fields = @(
                @{
                value = $notificationFields["value"];
                });
            };
        );
    }

    Invoke-Restmethod -Method POST -Body ($payload | ConvertTo-Json -Depth 4) -Uri $webhook
}

