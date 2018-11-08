package com.phonegap.helloworld;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import fi.iki.elonen.NanoHTTPD;

public class MockHttpServer extends NanoHTTPD {
    private final static String MIME_JSON = "application/json";
    private NanoHTTPD.Response.Status defaultResponseCode = NanoHTTPD.Response.Status.OK;
    private String defaultResponseBody = "default_response";

    public MockHttpServer(int port) {
        super(port);
    }

    public interface IMockHttpServerHandler {
        Response serve(String uri, Method method, Map<String, String> headers, InputStream inputStream);
    }

    private final Map<String, IMockHttpServerHandler> handlers = new HashMap<>();

    public void setHandler(String uriContains, IMockHttpServerHandler handler) {
        handlers.put(uriContains, handler);
    }

    public void setResponseHandler(final String uriContains, final String mimeType, final String body) {
        setHandler(uriContains, new IMockHttpServerHandler() {
            @Override
            public Response serve(String uri, Method method, Map<String, String> headers, InputStream inputStream) {
                return NanoHTTPD.newFixedLengthResponse(NanoHTTPD.Response.Status.OK, mimeType, body);
            }
        });
    }

    @Override
    public Response serve(IHTTPSession session) {
        Response result = null;

        String uri = session.getUri();
        Iterator<String> it = handlers.keySet().iterator();
        while(it.hasNext() && result == null) {
            String key = it.next();
            if (uri.contains(key)) {
                result = handlers.get(key).serve(uri, session.getMethod(), session.getHeaders(), session.getInputStream());
            }
        }

        if (result == null) {
            result = NanoHTTPD.newFixedLengthResponse(defaultResponseCode, MIME_JSON, defaultResponseBody);
        }

        return result;
    }

    public void setDefaultResponse(NanoHTTPD.Response.Status responseCode, String responseBody) {
        defaultResponseCode = responseCode;
        defaultResponseBody = responseBody;
    }
}
