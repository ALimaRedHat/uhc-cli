#
# Copyright (c) 2018 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

.PHONY: cmds
cmds: vendor
	for cmd in $$(ls cmd); do \
		CGO_ENABLED=0 \
		go build -o "$${cmd}" "./cmd/$${cmd}" || exit 1; \
	done

.PHONY: install
install: vendor
	go install ./cmd/uhc

.PHONY: tools
test: vendor tools
	ginkgo -r cmd pkg

.PHONY: fmt
fmt:
	gofmt -s -l -w cmd pkg

.PHONY: lint
lint: vendor
	golangci-lint run \
		--no-config \
		--issues-exit-code=1 \
		--deadline=15m \
		--disable-all \
		--enable=deadcode \
		--enable=gas \
		--enable=goconst \
		--enable=gocyclo \
		--enable=gofmt \
		--enable=golint \
		--enable=ineffassign \
		--enable=interfacer \
		--enable=lll \
		--enable=maligned \
		--enable=megacheck \
		--enable=misspell \
		--enable=structcheck \
		--enable=unconvert \
		--enable=varcheck \
		$(NULL)

vendor: Gopkg.lock
	dep ensure -vendor-only -v

.PHONY: tools
tools:
	which ginkgo || go get -v github.com/onsi/ginkgo/ginkgo

.PHONY: tools
clean:
	rm -rf \
		$$(ls cmd) \
		vendor \
		$(NULL)
