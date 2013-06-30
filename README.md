LSS-USDL Editor
=========

[![Creative Commons License](http://i.creativecommons.org/l/by/3.0/80x15.png)](http://creativecommons.org/licenses/by/3.0/)
This work is licensed under a [Creative Commons Attribution 3.0 Unported License](http://creativecommons.org/licenses/by/3.0/).

[Linked Service Systems for USDL (LSS-USDL)](https://github.com/rplopes/lss-usdl) is an ontology for modeling service systems in RDF. This is a graphical editor for LSS-USDL instances developed in Ruby on Rails. Its goal is to provide an abstranction to model service systems without having to edit RDF code and also to present a visual representation of modeled serivce systems. A deployed version for demonstration purposes is available at http://lss-usdl-editor.herokuapp.com.

## How to set up

This webapp was developed in Ruby, using the framework Ruby on Rails. So if you don't have Ruby installed in your computer, you should install it. Follow [this link](http://www.ruby-lang.org/en/downloads/) for all the information on how to install Ruby on your platform.

This application is versioned in Git, so if you don't have Git installed, you should also install it. Follow [this link](http://git-scm.com/) for all the information on how to install Git on your platform.

If you want to run this application on your computer and not on a production server, you also need to install the database SQLite, to store the information even when you exit the editor. Follow [this link](http://www.sqlite.org/) for the installation instructions. If you are configuring a production environment, then you should install [PostgreSQL](http://www.postgresql.org/) instead.

The first step to set up this app on your computer is to clone the Git repository. To do so, type the following in your terminal:

```
git clone git@github.com:rplopes/lss-usdl_editor.git
```

This will copy all the necessary files to the directory `lss-usdl_editor`. To go to that directory:

```
cd lss-usdl_editor
```

Now you need to install the required dependencies. If you don't have the Bundler gem installed:

```
gem install bundler
```

Now to install all other required gems just type:

```
bundle install
```

In order to save data we need to have a database and the right schema. We use the SQLite database because it is great for lightweight usage. If you are setting up a production environment, then the database is PostgreSQL. The required commands to generate the database and schema are:

```
rake db:create
rake db:migrate
```

Now everything is set. To start the application type:

```
rails server
```

## Useful links

 - [Linked Service Systems for USDL](https://github.com/rplopes/lss-usdl): Open source repository of the LSS-USDL model.
 - [USDL Incubator Group](http://www.w3.org/2005/Incubator/usdl): LSS-USDL is part of the research for service systems by the USDL research group.
 - [Linked USDL](http://www.linked-usdl.org): Similar project, focusing on service descriptions for customers. The third use case found in LSS-USDL's repository shows a service system modeled both in LSS-USDL and Linked USDL.
 - [Linked USDL core](https://github.com/linked-usdl/usdl-core): Repository for the core module of Linked USDL. The other modules may be found under the same Github profile.
 - [Semantic Web](http://semanticweb.org/wiki/Main_Page): Technologies such as RDF are a core component of LSS-USDL.