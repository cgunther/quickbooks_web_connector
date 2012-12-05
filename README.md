QuickbooksWebConnector
======================

QuickbooksWebConnector is a Redis-backed library for queueing up requests for the Quickbooks Web Connector software to fetch and perform. Responses from the Quickbooks Web Connector can also be handled if you need to take some action with the result.

QuickbooksWebConnector is heavily inspired by [QBWC](https://github.com/skryl/qbwc) and [Resque](https://github.com/defunkt/resque).

Requirements
------------

QuickbooksWebConnector has only been tested on Rails 3.2.9

Overview
--------

QuickbooksWebConnector allows you to create requests and place them on the queue for the Quickbooks Web Connector to fetch, with a response handler to handle the Quickbooks response.

A response handler is a Ruby class than responds to the `perform` method that receives the response XML as a string and any additional arguments you specified when enqueueing the request. Here's an example:

```ruby
require 'rexml/document'

class AddCustomerHandler

  def self.perform(response_xml, customer_id)
    customer = Customer.find(customer_id)
    customer.quickbooks_list_id = REXML::Document.new(response_xml).root.text('QBXMLMsgsRs/CustomerAddRs/CustomerRet/ListID')
    customer.save!
  end

end
```

To enqueue a request, you might add this to your model as an `after_create` callback, or maybe your controller's create action:

```ruby
class Customer

  after_create :add_to_quickbooks

  def add_to_quickbooks
    request_xml = <<-EOT
      <?xml version="1.0" encoding="UTF-8"?>
      <?qbxml version="6.0"?>
      <QBXML>
        <QBXMLMsgsRq onError="stopOnError">
          <CustomerAddRq>
            <CustomerAdd>
              <Name>FooBar Inc</Name>
            </CustomerAdd>
          </CustomerAddRq>
        </QBXMLMsgsRq>
      </QBXML>
    EOT

    QuickbooksWebConnector.enqueue request_xml, AddCustomerHandler, id
  end

end
```

Once Quickbooks Web Connector received your request and processed it, it would return a response, and your handler will get called like:

```ruby
AddCustomerHandler.perform response_xml, 1
```

Installing QuickbooksWebConnector
=================================

First include it in your Gemfile:

```
$ cat Gemfile
...
gem 'quickbooks_web_connector'
...
```

Next install it with Bundler:

```
$ bundle install
```

Mount the engine in your routes.rb

```
mount QuickbooksWebConnector::Engine => "/quickbooks_web_connector"
```

TODO: Add note about config in initializer

Now start your application:

```
$ rails server
```

Contributing
============

Once you've made your great commits:

1. [Fork](https://help.github.com/forking/) QuickbooksWebConnector
2. Create a topic branch: `git checkout -b my_feature`
3. Push to your branch: `git push origin my_feature`
4. Create a [Pull Request](https://help.github.com/pull-requests/) from your branch
5. That's it!
