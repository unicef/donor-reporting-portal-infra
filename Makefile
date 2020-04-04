WORKING_BRANCH?=docker
VERSION?=master

help:
	@echo '                                                                       '
	@echo 'Usage:                                                                 '
	@echo '   make fullclean                 remove docker images/containers/volumes'
	@echo '   make develop                   update develop environment         '
	@echo '   make git-dev-start             open feature named "${WORKING_BRANCH}" for each module and main repo'
	@echo '   make git-dev-finish            finish feature named "${WORKING_BRANCH}" for each module and main repo'
	@echo '   make git-dev-rebase            rebase  named "${WORKING_BRANCH}" for each module and main repo'

version:
	@cd donor-reporting-portal-backend && git checkout -q ${VERSION}
	@cd donor-reporting-portal-frontend && git checkout -q ${VERSION}
	$(MAKE) status

info:
	@echo 'docker images'
	@docker images | grep donor-reporting-portal
	@echo '------------------'
	@echo 'docker containers'
	@docker ps -a | grep donor_reporting_portal

clean:
	@docker rmi unicef/donor-reporting-portal-frontend:dev --force
	@docker rmi unicef/donor-reporting-portal-backend:dev --force
	@docker images | grep donor-reporting-portal


update:
	cd donor-reporting-portal-frontend && git reset --hard && git checkout
	git pull
	git submodule update

resync:
	cd donor-reporting-portal-backend && git reset --hard && git checkout develop && git pull && cd ..
	cd donor-reporting-portal-frontend && git reset --hard && git checkout develop && git pull && cd ..
	git add donor-reporting-portal-backend donor-reporting-portal-frontend && git commit -m "update submodules"
	$(MAKE) status


develop:
	git pull --recurse-submodules

fullclean:
	-docker stop `docker ps -f "name=docker-reporting-portal-infra*" -q`
	-docker rm `docker ps -a -f "name==docker-reporting-portal-infra*" -q`
	-docker rmi --force `docker images -f "ancestor=unicef/donor-reporting-portal-backend:dev" -q`
	-docker rmi --force `docker images -f "ancestor=unicef/donor-reporting-portal-frontend:dev" -q`
	-docker rmi --force `docker images -f "ancestor=unicef/donor-reporting-portal-db:dev" -q`
	-docker rmi --force `docker images -f "ancestor=unicef/donor-reporting-portal-proxy:dev" -q`
	-docker rmi --force `docker images -f "reference=unicef/donor-reporting-portal-*" -q`
	rm -rf volumes


git-dev-start:
	cd donor-reporting-portal-backend && git flow feature start ${WORKING_BRANCH}
	cd donor-reporting-portal-frontend && git flow feature start ${WORKING_BRANCH}
	git flow feature start ${WORKING_BRANCH}

git-dev-finish:
	cd donor-reporting-portal-backend && git flow feature finish ${WORKING_BRANCH}
	cd donor-reporting-portal-frontend && git flow feature finish ${WORKING_BRANCH}
	git flow feature finish ${WORKING_BRANCH}

git-dev-rebase:
	cd donor-reporting-portal-backend && git rebase ${WORKING_BRANCH}
	cd donor-reporting-portal-frontend && git rebase ${WORKING_BRANCH}
	git rebase ${WORKING_BRANCH}

status:
	@echo "Infra: (`git symbolic-ref HEAD`)"
	@git log -1
	@echo "Backend: (`cd donor-reporting-portal-backend && git st -b && cd ..`)"
	@cd donor-reporting-portal-backend && git log -1
	@echo "Frontend: (`cd donor-reporting-portal-frontend && git st -b && cd ..`)"
	@cd donor-reporting-portal-frontend && git log -1


update-backend:
	@docker rmi $(docker images |grep 'donor-reporting-portal-backend')
	@docker ps -a | awk ‘{ print $1,$2 }’ | grep <donor-reporting-portal-backend> | awk ‘{print $1 }’ | xargs -I {} docker rm -f {}


ssh-backend:
	@docker exec -it donor_reporting_portal_backend /bin/bash

ssh-frontend:
	@docker exec -it donor_reporting_portal_frontend /bin/bash
