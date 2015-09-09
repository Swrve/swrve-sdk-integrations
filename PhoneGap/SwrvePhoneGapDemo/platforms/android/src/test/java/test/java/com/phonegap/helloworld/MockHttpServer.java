package test.java.com.phonegap.helloworld;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

public class MockHttpServer extends NanoHTTPD {
    private final static String MIME_JSON = "application/json";
    private String defaultResponseCode = NanoHTTPD.HTTP_OK;
    private String defaultResponseBody = "";

    public interface IMockHttpServerHandler {
        Response serve(String uri, String method, Properties header, Properties params);
    }

    private final Map<String, IMockHttpServerHandler> handlers = new HashMap<String, IMockHttpServerHandler>();

    public void setHandler(String uriContains, IMockHttpServerHandler handler) {
        handlers.put(uriContains, handler);
    }

    public void setResponseHandler(final String uriContains, final String mimeType, final String body) {
        final NanoHTTPD.Response response = new NanoHTTPD.Response(NanoHTTPD.HTTP_OK, mimeType, body);
        setHandler(uriContains, new MockHttpServer.IMockHttpServerHandler() {
            @Override
            public NanoHTTPD.Response serve(String uri, String method, Properties header, Properties params) {
                return response;
            }
        });
    }

    public Response serve(final String uri, final String method, final Properties header, final Properties params, final Properties files) {
        Response result = null;

        Iterator<String> it = handlers.keySet().iterator();
        while(it.hasNext() && result == null) {
            String key = it.next();
            if (uri.contains(key)) {
                result = handlers.get(key).serve(uri, method, header, params);
            }
        }

        if (result == null) {
            result = new Response(defaultResponseCode, MIME_JSON, defaultResponseBody);
        }

        return result;
    }

    public void setDefaultResponse(String responseCode, String responseBody) {
        defaultResponseCode = responseCode;
        defaultResponseBody = responseBody;
    }
}
