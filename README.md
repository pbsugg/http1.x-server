#The Hat-tip Server

We're going to build an HTTP server from the ground up. No webrick, no thin, no sinatra, no rails. This challenge may very well take more than one day, and the material will build on itself as we go.

Given the length of the challenge, keep an eye on your code. You'll be working on the same code base for an extended period of time, so you'll need to strike a balance between over-designing and creating something that's a total hack.

As you complete releases, [add a tag](http://git-scm.com/book/en/v2/Git-Basics-Tagging) to that commit and label it with "r1", "r2", etc. That way we can quickly jump through your releases during code review.

## Release 1, Make yourself some Internet

Before we talk about HTTP, we need to talk about the "Transmission Control Protocol" or "TCP". TCP is a lower-level protocol that helps us send bytes of data between two machines on a network. It's one of the fundamental layers of the internet that you use every day. HTTP is built on top of it.

There are TCP _servers_ and TCP _clients_. Servers usually run in an infinite loop, waiting for a connection. Clients reach out to a server and request a connection, which the server can reject or accept.

Once a connection is established, the client and server can send and receive data between each other. At the end of communication, either party can close the connection.

For this first relase, you'll produce a TCP server that returns "Hello World" when a client connects, then closes the connection.

Use Ruby's [TCPServer](http://ruby-doc.org/stdlib-2.1.0/libdoc/socket/rdoc/TCPServer.html) class to create your server, the docs have a helpful example.

### Testing It
You'll need to test your server by connecting to it. You can make a request to a TCP server using Netcat, aka `nc` in your terminal. Here's how you'd connect to a TCP server running at IP 127.0.0.1 on port 2000:

```
~/my-server $ nc 127.0.0.1 2000
```

That line says "hey netcat, try to initiate a connection to the server running on port 2000 of the machine located at 127.0.0.1."

Hopefully your server accepts netcat's request to initiate a connection. When it does, the server and netcat can read and write data from/to each other. Anything the server writes will appear in your terminal. Anything you type in will get sent to the server.

`nc` will terminate when the server closes the connection.

When you finish, you should be able to connect and receive a response like this:

```
~/my-server $ nc 127.0.0.1 2000
Hello World
~/my-server $
```

Did you get it working? Congratulations, you just wrote your first server.

## Release Interlude, Rerun

You may have noticed that you need to kill and restart your server everytime you make a change. Nothing's sitting around waiting to reload your code for you.

If you find manually restarting your server to be annoying, check out the [rerun](https://github.com/alexch/rerun) gem. `rerun` watches files for changes. If a change is detected, `rerun` kills the current process and re-runs the command.

You can use `rerun` like this:

```
~/my-server $ rerun serv.rb
```


## Release 2, Disrupt Facebook

Let's make our server interactive. When a client connects to your server you should first read some input from them. Remember that you can send data from Netcat to the server by typing and hitting "enter".

The object returned by `TCPServer#accept` inherits from the [IO](http://www.ruby-doc.org/core-2.1.5/IO.html) class. You've already used `IO#puts` to send data to the client. Now you'll need to figure out how to _receive_ data.


When your server is reading data, make it respond to certain commands:

 * If the client sends "home" then send them a welcome message.
 * If the client sends "profile" then send them some profile information. You can invent the client's profile, it doesn't need to be fancy.
 * If the client sends something you don't understand, send an error message back.


Here's an example of what it might look like from the client's perspective:

```
~/my-server $ nc 127.0.0.1 2000
home
Welcome to my server!

~/my-server $ nc 127.0.0.1 2000
profile
User: Matt Baker
Favorite Quote:
There is science, logic, reason;
there is thought verified by experience.
And then there is California. --Edward Abbey

~/my-server $ nc 127.0.0.1 2000
foobar
I don't understand :(
```

You'll need to kill and re-start your server everytime you make a change.

Don't forget to tag the release when you complete it.

> Side-note: This release is less silly than you think. Before Facebook, we had the [finger](https://kb.iu.edu/d/aasp) protocol.

## Release Interlude: HTTP

We've been using TCP to communicate between our server and our client. TCP is lower level than HTTP, it lets people send bytes over the internet. You've been sending bytes yourself, each character you send is represented as one byte.

You also made a simple _text protocol_ on top of TCP. In your protocol, if someone types "welcome" you send one kind of response. If they type "profile" you send a different kind of response.

At the end of the day, a protocol is just an agreement that a client and server will send and receive messages in a specific format.

Web browsers speak a text protocol too, it's called the Hyper Text Transfer Protocol (HTTP). There are certain messages you can send to the server, known as **requests**, and certain messages you can expect to get back, known as **responses**. It's not altogether different from the protocol you just made.

The cool part about any protocol is you can build software that "speaks it". If we can write a server that reads and writes messages in the right format, we should be able to visit it with any HTTP client, including your browser.

### HTTP's Request-Response Cycle
Let's learn a little more about how HTTP servers and clients talk to each other. Check out Wikipedia's [example](http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Example_session) of an HTTP request-response cycle. Scrutinize it, because we're going to be implementing this.

Notice that HTTP server doesn't _just_ send back a chunk of HTML. It also specifies a response code and some headers that contain meta-data about the response.

## Release 3: Hello, HTTP

We already know how to make a TCP server, so let's make one that speaks HTTP. You'll be testing your HTTP server with netcat, just as before.

For your first release of this HTTP Server, you need to send back a web page when a client contacts your server. We're going to send the same page back no matter what. We will ignore the client's _request_, meaning you can type anything into netcat, hit enter, and your server will always send the same thing. However, whatever your server sends _back_ must be a properly formatted HTTP response.

### The devil's in the details

As you saw in the Wikipedia [example](http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Example_session), you can't just send back some HTML from an HTTP server, you have to conform to HTTP's _response format_. Refer back to the [example request-response cycle](http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Example_session) and the more detailed [response format](http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Response_message) description. It's up to you to determine how to format and send an appropriate HTTP response from your server.

When it comes time, make sure your response has these [response headers](http://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Response_fields):

 * Server
 * Content-Type (should be the HTML [MIME type](http://en.wikipedia.org/wiki/Internet_media_type))
 * Content-Length
 * Connection (should be `close`, we don't want to leave it open)

And use this as the body of the response you create:

```
<html>
<head>
  <title>Welcome</title>
</head>
<body>
  <h1>Hello World</h1>
  <p>Welcome to the world's simplest web server.</p>
  <p><img src='http://i.imgur.com/A3crbYQ.gif'></p>
</body>
</html>
```

> Remember your "heredoc" syntax in Ruby (aka multi-line strings) since we're sending big chunks of text.
>
>You could also put your HTML in a text file and have your ruby program read it into a string, but you might save that re-factor for later.

Finally, just like code, protocols are very specific. This will be a test of your attention to detail — you need to read and implement the formats precisely. You can double-check your work by using the `curl` HTTP client from the command line. Make sure it gets back your HTML:

```
curl http://127.0.0.1:2000
```

## Release Interlude: Natural Resources

Currently our server sends the same response no matter what we request from netcat, but HTTP is all about _resources_. Resources are the **nouns** in the HTTP protocol, things we can access and interact with. You've accessed resources on the web many times, for example `/users/1/friends` or `/welcome`.

We interact with resources using their "URI", or "universal resource identifier". For example, we might assign the URI `/users` to the list of users in our system. We would write code on our server that lets us access that list over the HTTP protocol using that URI.

A URI that has a protocol (say, http) and machine identifier (like 127.0.0.1) is known as a _URL_, or "universal resource _locator_". `/welcome` is a URI, `http://127.0.0.1/welcome` is a URL.

## Release 4, Learning How to Listen

We'll be creating two resources in this release, identified by the URIs `/welcome` and `/profile`.

`/welcome` will provide a resource you've already implemented, the landing page:

```
<html>
<head>
  <title>Welcome</title>
</head>
<body>
  <h1>Hello World</h1>
  <p>Welcome to the world's simplest web server.</p>
  <p><img src='http://i.imgur.com/A3crbYQ.gif'></p>
</body>
</html>
```

`/profile` will provide a resource representing a user's profile. For now it's just basic static text:

```
<html>
<head>
  <title>My Profile Page</title>
</head>
<body>
  <p>This is my profile page.</p>
</body>
</html>
```

Now we have two resources, identified by their two URIs. This means we can't ignore the client anymore. We need to be able to parse HTTP **requests** to know _which_ resource the client wants.

Spend some time learning about the [HTTP request format](http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_message). This is the format you'll use when you craft the request message you send to your server from `nc`.

Your server needs to be able to parse these request messages from clients and serve back appropriate responses. You might look back at that [request-response example](http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Example_session) again to see it all working together.

When you formulate your request message in netcat, use the following [request headers](http://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Request_fields):

 * Host (we don't have a domain, our server is 127.0.0.1:2000)
 * User-Agent

Finally, if a client requests any resource other than the two we're making available, send a response indicating that [we don't have it](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes). Hint, this won't be a `200 OK`.

When you're finished you should be able to:

 * Request `/welcome`
 * Request `/profile`
 * Request `/foobarbaz` and get an appropriate response indicating the resource can't be found

### Better tools

By now you're probably tired of typing stuff into `nc`. Let's look at some better tools we can use now that we understand the fundamentals of the HTTP protocol.

When (and only when) you are able to successfully request your two resources (plus the 404) from the server with `nc`, check out the two tools below.

#### curl

`curl` is an HTTP client you can use on the command line instead of doing everything by hand with netcat. For example, try this:

```
curl -v http://127.0.0.1:2000/welcome
```

We're using a bonified HTTP client, now. This is a good test of your HTTP server.  If you messed up any of the protocol, `curl` won't be able to request and receive your welcome page successfully. Fix any bugs you find.

#### Chrome

Once `curl` works you can try out another HTTP client on your computer — your web browser. Visit [http://127.0.0.1:2000/welcome]
(http://127.0.0.1:2000/welcome) and see if it works.

Whether it worked or not, open up Chrome's dev tools and visit the network tab, you might need to refresh the page after opening the tab to start it capturing.

The network tab shows you all the traffic, including requests and responses, between you and the HTTP server. When I say everything, I mean everything:

 * HTTP requests
 * AJAX requests
 * Websocket connections
 * Static assets (JS, CSS, images, fonts)
 * And more

Click on the entry for your GET request (`welcome`) and look at all the data it provides you.

This is going to be very, very important tool going forward. You'll have some version of this tab open for the rest of your web development life.

## Release Interlude: Pay Down Your Debt

Time to pause and reflect. If your code is well structured and properly modular, it should be trivial to add another resource to your server. If it's not, you need to invest time in _paying down your technical debt_. This will slow your progress in the short term, but pay long term dividends.

We're just getting started with this challenge. Ask yourself:

 * Can I easily add new resources?
 * Can I easily add new responses?
 * Can I easily add new response headers?
 * Can I easily parse new request headers?

We're in an object-oriented language, so you'll probably end up with a class representing your HTTPServer. It'll need to handle requests for resources, serving responses, and starting its event loop (the part where it starts accepting clients).

### Facilitating test coverage
You'll be adding test coverage to your entire server next.

As you refactor, favor methods that accept the data they need as _arguments_ and _return_ their work as a result. These are easy to test, since you can pass something in and assert that the result is what you expect. Methods that read and write data from instance variables are more difficult to setup.

Decompose your code into as many small methods as is reasonable.  It's _easy_ to test small methods. It's _hard_ to test monoliths.

## Release 5, Start Testing
After your refactor, it's time to add RSpec (if you haven't already). Your methods should be small, numerous, and  striving to be "single responsibility". If you test all your individual methods, you should be able to prove your webserver works even without the browser or netcat.

You don't need to go test-first as you develop, but you'll want to implement tests for all the functionality you've added, as well as anything you add from here on out.

**From here on out, code without correspending tests is not complete.** Your instructor is available to help you think about what to test and how.

## Take a Break

What have we accomplished so far? Quite a bit! We have:

 * Learned about TCP, one of the foundational layers of the internet
 * Learned about protocols
 * Learned about the HTTP protocol format, HTTP resources, and URIs
 * Produced a simple HTTP server that handles the request-response cycle for GET requests of HTTP resources
 * Added support for query parameters in our HTTP server
 * Added and maintained full test coverage of our HTTP server

There are three more releases to go, and they're not easy. Get up, stretch, take a break. This is a moment to take a breather and clear your mind before diving back in.

## Release 6, Say My Name

Let's make our application a little friendlier. If we access the `/welcome` resource it gives us a "hello world" page, but it'd be nice if we could provide a parameter to it with our name.

Extend your server to handle **query parameters**. The formal definition of query parameters can be found in [RFC3986](http://tools.ietf.org/html/rfc3986#section-3.4), the specification for Uniform Resource Identifiers (URIs):

> [...] The query component is indicated by the first question mark ("?") character and terminated by a number sign ("#") character or by the end of the URI. [...]  query components are often used to carry identifying information in the form of "key=value" pairs

For our purposes, we'll want to be able to accept first and last names from the query string when we access the `/welcome` resource.

`/welcome?first=Burt&last=Malkiel` will yield a page that looks like this:

```
<html>
<head>
  <title>Welcome</title>
</head>
<body>
  <h1>Hello Burt Malkiel!</h1>
  <p>Welcome to the world's simplest web server.</p>
  <p><img src='http://i.imgur.com/A3crbYQ.gif'></p>
</body>
</html>
```

Hopefully in the course of this release you've built a small URI parser method that extracts query parameters.

Lucky you, that'll be easy to test.

## Release Interlude: Clients and Users

Back? Before we move on, let's get some terminology straight. In this challenge we're going to make a distinction between "clients" and "users."

A _client_ is "a piece of software that connects to your server." We've used netcat, curl and Chrome as HTTP clients so far.

A _user_ is a person that uses your system. A user might have multiple clients. For example, I, as a user, might access your site from multiple clients — say Firefox and Chrome.

So, `clients == software`, `users == people`. Good? Good.

## Release Interlude: Client of Choice

Chrome's developer tools will make it easier to debug than netcat or curl, so use that as your client from here on out.

## Release 7, The Panopticon

Sometimes tracking a client in HTTP is important, especially on the web. It helps us know who's logged in, or watch how a client uses our site.

We're going to implement the most basic tracking of all. Let's build a resource that displays the number of times a client has visited our server. We'll call the resource `/visits`.

For example, if I opened up Chrome and visited my server 4 times, I'd expect to see this at `/visits`:

```
<html>
<head>
  <title>Visit count</title>
</head>
<body>
  <p>You have visited this page 4 times.</p>
</body>
</html>
```

Think this through before you jump in. When your server accepts a connection, do we know it's a client who's visited before? How can you tell the difference between me accessing your site on _my_ computer and you accessing it on yours? You and I should see two different counts when we go to `/visits`.

Spend a few minutes considering this before you read on.

If you're not really sure how to accomplish our goal, good. You're recognizing a fundamental characteristic of HTTP: it's **stateless**. That means that when a client requests a resource, we send something back, and then our server forgets the client ever existed, we don't save any information about them.

If we want to track clients accessing our server, the fact that HTTP is stateless is a big problem.

Look through the [request](http://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Request_fields) and [response](http://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Response_fields) headers again. Is there _anything_ that lets us indentify one client from another?

Also think about how you're going to test this with a browser that proves your code is working correctly. What will you need to do and why?

## Release 8, Turn On, Log In, Drop Out

We're making headway. It's neat that we can track clients, but we really want to track _users_. If I, as a user, visit your website in Chrome then you're tracking the number of times I visit your site in Chrome. So far so good. But what if I  access your site from a different web browser? What will happen to my visit count?

Consider this problem and how you might solve it.

Instead of tracking _clients_, let's track _users_. To do that, our server needs to have the idea of a User to begin with.

We're going to implement a rudimentary login system. Keep it simple, you can have a hardcoded list of two or more users on your server, each with a username and password.

Add a resource, `/login`. Users can login to your system by passing query parameters, for example `/login?username=matt&password=1234`.

If users authenticate, ensure you're tracking them no matter what browser they're on. Regardless of what browser they use, accessing `/visits` should show the same number and track visits in each.

At this point, it's ok to stop tracking non-authenticated users.

## Release Interlude: Method Acting

We've talked about _resources_ plenty in HTTP, but we haven't talked about _verbs_. Verbs, or "methods", are how we interact with nouns, or "resources" in HTTP. So far the only method we've used is "GET", which allows us to fetch a resource. GET requests don't have side effects, they're a "read only" operation.

GET makes sense when we want to read a web page — that's definitely read-only. But when a user logs in to our server, that's no longer a read-only operation, we're making something _happen_ on the server. GET probably isn't the right choice.

Read through the HTTP [request methods](http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods), including the section on "Safe Methods". Should you be using a safe or un-safe method for login? Determine which method is most appropriate.

Note: **Clear your cookies** before moving on.

## Release 9, Right Method, Right Time

For our purposes, POST is a logical method to use for logging in. It's un-safe, so it implies that accessing `/login` via `POST` will probably have a side-effect. More technically, a POST:

> "requests that the server accept the entity enclosed in the request as a new subordinate of the web resource identified by the URI."

We could argue the session we create when a user logs in is a "new subordinate." So let's use the POST method to handle logging in instead of GET.


### Routing First

Don't jump in and build your login system all-at-once. First, update your server to support clients requesting resources based on a URI _and_ a method. Have two resources that send something different back based on whether a client accesses them with a POST or GET.

You can test with curl:

```
~/my-server $ curl -X GET http://127.0.0.1:2000/test
Foo
~/my-server $ curl -X POST http://127.0.0.1:2000/test
Bar
```

### Forms Please

Now that you have support for different methods, let's build a login form. `GET /login` should show the login form, and `POST /login` will actually log the user in.

You know how to make forms, and you know how to make them POST to a url. But how do we get the data from that form POST on the server side?

We know how to send data in a GET request, we use a query string like `?search=sightglass`, but we don't know how to read data from a POST request. Since users will be logging in from form submissions, we should see how the browser sends forms.

POST to your server in Chrome using your login form (`GET /login`) and watch the network tab. In your server, also put in some logging statements that show the requests it receives.

Your goal is to _reverse-engineer_ the message format the browser is using to send data in the request. We know it's not query parameters in the resource URI, so where is that form data in the request and how is it formatted?

Once you determine the format, check your guess against the ["application/x-www-form-urlencoded"](http://en.wikipedia.org/wiki/POST_(HTTP)#Use_for_submitting_web_forms) format.

Now that you understand how data is coming in, you can parse and use **POST data** the same way you parsed and used data from the query parameters several releases ago. Use this to implement a login form.

**Note:** This is probably a good time to mention that a request can only have a body if the request also specifies `Content-Length`. This is good news for you as someone parsing requests.

## Release 10, Say My Name... again

Now that we have users and sessions, let's update the `/profile` route with a friendly message. Greet the currently logged-in user.

```
<html>
<head>
  <title>matt's Profile Page</title>
</head>
<body>
  <p>Welcome matt!</p>
</body>
</html>
```

### And if they're not logged in?

If there is no user logged in, redirect them to `/login`. You'll probably want to go back and review the [HTTP response codes](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes).


## Release 11, Late Registration

Let's allow users to register new accounts on our servers. Create a resource at `/register`. The GET should provide a registration form with a username and password. The POST should actually add a user to your system.

Update `/welcome` to show a list of all users registered with the system.

> Note: In practice, we'd *never* want to leak this kind of information. We're effectively giving an attacker a list of users in our system and saying "come at me."

Now clients can register accounts on your server, and view a list of all registered users at `/welcome`.

## Congratulations

You've built Sinatra.

![](http://i.imgur.com/xc6G2qh.gif)
