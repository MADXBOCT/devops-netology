Vector Role
=========

This role install Vector. 

Role Variables
--------------

|vars| description|
|------|--------------------|
| vector_version | Version of Vector to install |
| vec_arc_var | Desired machine architecture | 
| vector_home | Vector home directory |

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: vector }

License
-------

MIT

Author Information
------------------

Sergey Gudimov
