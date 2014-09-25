#Grapevine JS Framework

---

##MVC: Your new best friends

Grapevine, like most other development environments operates on a MV* framework, three pieces of a program that talk to each other to publish, update, and display information between the front- and back-ends.

####Model
The Model consists of saved data, logic, and functions that make up the app. Think of this as the stockroom in a shoe store. It has a listing of the amount items stored and where they are stored.

####View
The View represents the information stored in the Model. Think of it as the way the shoes are displayed and interacted with in the store.

####Controller
The Controller is the go-between the Model and the View. It hadles the fetching information from Model and also any updates that are made to the Model by the View. Like a salesperson at the store, they will bring out shoes (the data from the Model) and will update the stockroom when a pair of shoes is bought by the customer.

---


##Best Practices and Policies
There's plenty of things to concern yourself with when building with Grapevine, but we'd like to make your life as easy as possible.
####Modularity
Separation of Concerns is the key, here. Take note when building controlers and views that you're allowing each of these to exist and fail independently.

This also means that each separate function of the app is built into different **modules**, often build in parallel with a Django app. You'll notice the `coffee` directory is divided into different directories like `app`, `facebook`, etc.

####[Required Files](id:RequiredFiles)
You'll notice a line at the top of most of your template files:

```
define [
  'BaseController'
],
(BaseController) ->

```

This is where you define your component's dependencies. When you want to include another component, library, controller, view, etc. you add it to the 'define' list and and to the function's arguments. If you're using a component, also make sure to specify the the path to the component i.e:`./module/component`

Take a look at [Require.JS's](http://requirejs.org/docs/jquery.html) documentation for more information.


---

##Building a Module

Lorem ipsum dolor sit amet, consectetur adipisicing elit. Porro voluptatum veritatis, quod excepturi! Dolorum illo cumque soluta possimus perspiciatis, quos quibusdam delectus aliquam voluptatem nemo ab eligendi! Dolores, quam sunt.

```
cd [app directory]/static_src
```

Next, use Yeoman's generator to build a module:
```
yo grapevine:module [module name]
```

And a module template has been built for you, automatically! In the module's `main.coffee` file... Lorem ipsum dolor sit amet... fill in more...

```
controller: MyController
```

or

```
controller:
  foo: FooController
  bar: BarController
```

and

```
constants:
  API_KEY: "ABC123"
```

later retrieved anywhere in the module or the module's MVC:

```
@sandbox.constant()
@sandbox.constant().API_KEY
```

or retreive another module's constants:

```
@sandbox.constant('user').FULL_NAME
```


---


##Creating Your First Controller

We'll start out by building our controller using a template built with [Yeoman](http://yeoman.io/). Load up your terminal and change directories into the module you want to build in.

```
cd [app directory]/static_src/coffee/[module]
```

Next, use Yeoman's generator to build a controller:

```
yo grapevine:controller [controller name]
```
And a controller template has been built for you, automatically! You'll have to make sure that your controller is included in your **module**. In the module's `main.coffee` file, include it in the list and arguments at the top of the file. See [Required Files](RequiredFiles).

Next, you will have to make sure the object is actually initialized in the module.

######Modules with one controller

If you only have one controller in your Module, you can simply define your controller with the instance variable `controller` inside your module and the BaseModule class will take care of the rest.

```
class [YourModule] extends BaseModule

  controller: [YourController]

  ...

  # This method is included in BaseModule so you won't
  # need to include it unless you want to edit it
  createController: (Controller) ->
    # create the controller
    @controller = new Controller()

```

######Modules with multiple controllers

Sometimes you might have a complex module with multiple included modules. Now the `controller` instance variable will actually be a hash of the controllers you wish to include in the Module. You will also be using a factory to build the controllers inside of the `createController` method. This time, you'll have to override BaseModule's `createController` method.

```
class [YourModule] extends BaseModule

  controller:
    main: MainController
    second: SecondController

  ...

  createController: (factory) ->
    # get the controllers
    Main_Controller = factory 'main'
    Second_Controller = factory 'second'

    # init the controllers
    main_controller = new Main_Controller()
    second_controller = new Second_Controller()

    # assign a primary controller for modules who are
    # expecting this module to return something
    @controller = main_controller


```

##Creating Your First View
Like the controller, we'll start out by building our controller using a template built with [Yeoman](http://yeoman.io/). In the same module's directory, use Yeoman's generator to build a view:

```
yo grapevine:view [view name]
```

Similar to initializing the controller, we'll have to initialize our views in the module as well as the controller.

######Initialize in the Module

As with the controller, make sure the module is loading in your views in the define list and the function arguments at the top of the file. See [Required Files](RequiredFiles). Next, add your views as a settings hash to the initialization of the controller, so the controller knows to expect the views.

```
createController: (factory) ->
  ...

  # init the controllers
    main_controller = new Main_Controller
      views:
        Foo :  FooView

```

######Initialize in the Controller
Open up your new controller's file and look at the initialize method for the Controller. This is where you will initialize your views.

If you're basing your view off of `BaseView` there are plenty of options you can pass into to the view when initializing it, which you can view in [Backbone's documentation](http://backbonejs.org/#View-constructor). For now, let's concern ourselves with making a view focused on an `el` (element).

```
class [YourController] extends BaseController

  initialize: (settings) ->
    # setup my new view
    new settings.views.[View Name]
      el: ('.my-element')


```

#Routers
Routers are covered in depth in backbone's docs, [so feel free to read up on them.](http://backbonejs.org/#Router)

Like views and controllers before them, we can setup routers using a Yeomen generator. Change directories into the module you want to use and make a router.

```
yo grapevine:router [router name]
```

Just like initializing a view or controller, we have to also initialize a router in the module and the controller.

######Initialize in the Module

Make sure the module is loading in your routers in the define list and the function arguments at the top of the file. See [Required Files](RequiredFiles). Next, add your routers as a settings hash to the initialization of the controller, so the controller knows to expect the routers.

```
createController: (factory) ->
  ...

  # init the controllers
    main_controller = new Main_Controller
      routers:
        Foo :  FooRouter

```

######Initialize in the Controller
Open up your new controller's file and look at the initialize method for the Controller. This is where you will initialize your routers.

```
class [YourController] extends BaseController

  initialize: (settings) ->
    # setup my new router
    new settings.routers.[Router Name]

```

Here you have the option to assign routes when you create it, or you can do it directly inside the router coffee script file.

You will also have to startup [Backbone's Global History Router](http://backbonejs.org/#History) Add this to the controller's initialization.

```
Backbone.history.start()
```

######Setup your Routes
Referencing Backbone's docs, you can setup a number of routes and assign different triggers to them.

```
routes:
  "hello"           : "hello_welcome"
  "greeting/:text"  : "greeting"
```

For example, the first route will trigger an action called `hello_welcome` if your URL has the hash `#hello` appended to it. You can hook into the trigger with:

```
@sandbox.on 'route:hello_welcome'

```

The second route will trigger the action `greeting`, but it will also accept a parameter which can be passed to the trigger. If your URL has the hash `#greeting/hello_there`, the route will trigger the action but also pass with it the string `hello_there`.