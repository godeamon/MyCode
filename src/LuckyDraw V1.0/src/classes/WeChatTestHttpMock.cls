@isTest
public class WeChatTestHttpMock implements HttpCalloutMock
{
    private HttpResponse resp;
    private List<HttpResponse> responseList;
    private Integer currentResponse;

    public WeChatTestHttpMock(String testBody, String testStatus, Integer testStatusCode)
    {
        this.resp = buildHttpResponse(testBody, testStatus, testStatusCode);
    }

    public WeChatTestHttpMock(Blob blobBody, String testStatus, Integer testStatusCode)
    {
        this.resp = buildHttpResponse(blobBody, testStatus, testStatusCode);
    }

    public WeChatTestHttpMock(List<WeChatTestHttpMock.MockResponse> responses)
    {
        this.responseList = new List<HttpResponse>();
        for (WeChatTestHttpMock.MockResponse response : responses)
        {
            HttpResponse res;

            if(response.responseBody != null)
            {
                res = buildHttpResponse(response.responseBody, response.responseStatus, response.responseStatusCode);
            }
            else
            {
                res = buildHttpResponse(response.responseBlobBody, response.responseStatus, response.responseStatusCode);
            }
            this.responseList.add(res);
        }
        this.currentResponse = 0;
    }

    public HTTPResponse respond(HTTPRequest req)
    {
        if (this.resp != null)
        {
            return this.resp;
        }
        else if (this.responseList != null && !this.responseList.isEmpty())
        {
            this.currentResponse++;
            return this.responseList[currentResponse - 1];
        }
        return null;
    }

    private HttpResponse buildHttpResponse(String body, String status, Integer statusCode)
    {
        HttpResponse response = new HttpResponse();
        if (body != null)
        {
            response.setHeader('Content-Type', 'application/json');
            response.setBody(body);
        }
        if (status != null)
        {
            response.setStatus(status);
        }
        if (statusCode != null)
        {
            response.setStatusCode(statusCode);
            if (statusCode == 301 || statusCode == 302)
            {
                response.setHeader('Location', 'http://redirect.com');
            }
        }
        return response;
    }

    private HttpResponse buildHttpResponse(Blob body, String status, Integer statusCode)
    {
        HttpResponse response = new HttpResponse();
        if (body != null)
        {
            response.setHeader('Content-Type', 'image/jpg');
            response.setBodyAsBlob(body);
        }
        if (status != null)
        {
            response.setStatus(status);
        }
        if (statusCode != null)
        {
            response.setStatusCode(statusCode);
            if (statusCode == 301 || statusCode == 302)
            {
                response.setHeader('Location', 'http://redirect.com');
            }
        }
        return response;
    }

    public class MockResponse
    {
        public String responseBody { get; private set; }
        public Blob responseBlobBody { get; private set;}
        public String responseStatus { get; private set; }
        public Integer responseStatusCode { get; private set; }

        public MockResponse() {}
        public MockResponse(String testBody, String testStatus, Integer testStatusCode)
        {
            this.responseBody = testBody;
            this.responseStatus = testStatus;
            this.responseStatusCode = testStatusCode;
        }

        public MockResponse(Blob testBody, String testStatus, Integer testStatusCode)
        {
            this.responseBlobBody = testBody;
            this.responseStatus = testStatus;
            this.responseStatusCode = testStatusCode;
        }
    }
}