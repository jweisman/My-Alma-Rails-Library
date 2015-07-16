function ajax_stream_log(url, element, callback)
    {
        try
        {
            var xhr = new XMLHttpRequest();  
            xhr.previous_text = '';
            var buffer = true;

            xhr.onerror = function() { alert("[XHR] Fatal Error."); };
            xhr.onreadystatechange = function() 
            {
                try
                {
                    if (xhr.readyState == 4) 
                    {
                        // If request is buffered, show entire response
                        if (buffer) element.innerText = element.innerText + xhr.responseText;
                        callback();
                    }
                    if (xhr.readyState > 2)
                    {
                        buffer = false;
                        var new_response = xhr.responseText.substring(xhr.previous_text.length);
                        element.innerText = element.innerText + new_response;
                        xhr.previous_text = xhr.responseText;
                    }   
                }
                catch (e)
                {
                    alert("<b>[XHR] Exception: " + e + "</b>");
                }
                 
                 
            };
     
            xhr.open("GET", url, true);
            xhr.send("Making request...");      
        }
        catch (e)
        {
            alert("<b>[XHR] Exception: " + e + "</b>");
        }
    }