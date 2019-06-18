# simple powershell version of the fortune command
function Get-Fortune()
{
    if ((Get-Random -Maximum 2) -eq 0 ) {
        $jsonQuote = ((Invoke-WebRequest -UseBasicParsing 'http://quotes.stormconsultancy.co.uk/random.json') | convertfrom-json)
        return "$($jsonQuote.quote)`n`t--$($jsonQuote.author)"
    }
    else {
        return ((Invoke-WebRequest -UseBasicParsing 'http://randomuselessfact.appspot.com/random.txt?language=en').content.replace('>',"").trim() -split '\n')[0]
    }

    
}