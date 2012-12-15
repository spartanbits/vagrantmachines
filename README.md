# Introduction

Virtual machines for internal use is a project to generate virtual machines with programs
and scripts in an automatic way, trying to avoid this boilerplate task and to take control
about test machines where projects are developed.

To do it we are using 2 programs:

* [veewee](https://github.com/jedi4ever/veewee): to generate box files, base file to execute virutal machines.
* [vagrant](http://vagrantup.com/): to use box files

Virtual machines are generated for [virtualbox](https://www.virtualbox.org/), so install it.

# Generate box files with veewee

To install veewee follow [current stable](https://github.com/jedi4ever/veewee/tree/v0.2.2)
or the [last release](https://github.com/jedi4ever/veewee/blob/master/doc/installation.md).

This machine has been generate with [last release](https://github.com/jedi4ever/veewee/blob/master/doc/installation.md)

To install veewee:

```gem install veewee```

## Steps to make a virtual machine

To generate virtual machine:

```
cd gochatserver
veewee vbox build 'ubuntu-10.04.4-server-amd64'
```

Wait for a while ...

Verify virtual machine:

1. Validate machine: ```veewee vbox validate 'ubuntu-10.04.4-server-amd64'```
2. Now test acceess to machine through ssh: ```ssh -p 7222 vagrant@localhost```
3. Make the box file: ``` vagrant package --base 'ubuntu-10.04.4-server-amd64' --output ''ubuntu-10.04.4-server-amd64.box'```

# Work with generated virtual machines

If you don't have vagrant installed (type vagrant on your terminal to check it),
please install latest version of [vagrant](http://downloads.vagrantup.com/)

If you have the box file use:

```vagrant init ubuntu-10.04.4-server-amd64 ubuntu-10.04.4-server-amd64.box```

If not:

```vagrant init box-name box-url```


It will generate a Vagrantfile in your current directory

Here you can edit network, port forwarding, gui mode, shared folders and other automatic tasks with puppet.

To start vagrant machine type:

```vagrant up```

A new virtualmachine will be booted and a ssh terminal is available through:

```vagrant ssh```

You can halt, reboot or resume your vagrant machine with:

```vagrant [halt] [reboot] [resume]``` commands

To destroy the vagrant machine type:

```vagrant destroy``` and it will be removed from your Virtualbox catalog.

To remove imported box type:

```vagrant box remove box-name```














