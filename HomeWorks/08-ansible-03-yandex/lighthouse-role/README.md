Role Name
=========

This role install lighthouse

Role Variables
--------------

| vars           | description|
|----------------|--------------------|
| lighthouse_url | Download URL for lighthouse|
| arc_name       | Temp archive name|
| tmp_fld        | Temp folder for download
| websrv_home    | Nginx home folder location|

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: lighthouse-role }

License
-------

MIT

Author Information
------------------

Sergey Gudimov