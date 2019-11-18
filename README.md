Donor Reporting Portal Deployment Stack
============================================


### Full Stack Links

  - Development - https://github.com/unicef/donor-reporting-portal-infra
  - Backend - https://github.com/unicef/donor-reporting-portal-be
  - Frontend - https://github.com/unicef/donor-reporting-portal-frontend
  


Development
============================================


Initialization
------------------------------

Be sure you have a `.env` file in the project home.

```bash
git pull --recurse-submodules
```
 

Start development
------------------------------

```bash
   docker-compose up
```


Update Backend
-----------------------------
If you need to update the development image to latest `:dev` version use:

```bash
   docker-compose pull
```

then most probably you will need to run migrations

```bash
   make ssh-backend
   django-admin migrate
```

Update Frontend
-----------------------------
```bash
   cd donor-reporting-portal-frontend
   git pull
   npm install
```