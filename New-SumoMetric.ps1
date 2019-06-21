# Send data (logs, metrircs etc...) to sumo 
# New-SumoMetric -sumoEndpoint "https://jo...." -stringDetails "User Authentica...";
function New-SumoMetric()
{    
    param
    (
        [String][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$sumoEndpoint, 
        [String][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$stringDetails
    )

    $error.Clear();
    $request = Invoke-WebRequest -Uri "$sumoEndpoint?$stringDetails";
    $message = "Data sent!";

    if($error.Count -eq 1){
        $code =  $error[0].Exception.Response.StatusCode.value__; 
        if($code -eq 0){
            $message = $error[0].Exception.Message;
        }
        elseif( $code -gt 0){
            $message = $error[0].Exception.Response.StatusDescription;
        }
        else{
            $message = "Unknown problem, return code is negative.";
        }
    }
    elseif($error.count -gt 1){
        $code = 0;
        $message = "Unknown problem, multiple exceptions.";
    }

    write-host $message;
}
