# -*- coding: iso-8859-15 -*-
"""critical_path FunkLoad test

$Id: $
"""
import unittest
from funkload.FunkLoadTestCase import FunkLoadTestCase
from webunit.utility import Upload
from funkload.utils import Data
#from funkload.utils import xmlrpc_get_credential

import random

class CriticalPath(FunkLoadTestCase):
    """Test Swapmeet's critical path

    This test use a configuration file CriticalPath.conf.
    """

    def setUp(self):
        """Setting up test."""
        self.logd("setUp")
        self.server_url = self.conf_get('main', 'url')
        # XXX here you can setup the credential access like this
        # credential_host = self.conf_get('credential', 'host')
        # credential_port = self.conf_getInt('credential', 'port')
        # self.login, self.password = xmlrpc_get_credential(credential_host,
        #                                                   credential_port,
        # XXX replace with a valid group
        #                                                   'members')

    def test_critical_path(self):
        # The description should be set in the configuration file
        server_url = self.server_url
        # begin of test ---------------------------------------------

        # /tmp/tmpxcCX8v_funkload/watch0005.request
        self.post(server_url+"/users/sign_in", params=[
            ['utf8', '\xe2\x9c\x93'],
            ['user[login]', 'user'+str(random.randint(1,19))],
            ['user[password]', 'password'],
            ['user[remember_me]', '0'],
            ['commit', 'Log in']],
            description="Post /users/sign_in")
        # /tmp/tmpxcCX8v_funkload/watch0007.request
        self.get(server_url+"/offers/new",
            description="Get /offers/new")
        # /tmp/tmpxcCX8v_funkload/watch0008.request
        self.post(server_url+"/offers", params=[
            ['utf8', '\xe2\x9c\x93'],
            ['offer[title]', 'TestingOffer'],
            ['offer[description]', 'Just for testing'],
            ['offer[image]', Upload("")],
            ['offer[tag_list]', 'test'],
            ['commit', 'Create Offer']],
            description="Post /offers")
        # /tmp/tmpxcCX8v_funkload/watch0007.request
        self.get(server_url+"/offers/666/bid",
            description="Load the new bid page")
        # /tmp/tmpxcCX8v_funkload/watch0008.request
        self.post(server_url+"/offers/666/bid", params=[
            ['utf8', '\xe2\x9c\x93'],
            ['offer[title]', 'TestingBid'],
            ['offer[description]', 'Just for testing'],
            ['offer[image]', Upload("")],
            ['offer[tag_list]', 'test'],
            ['commit', 'Bid on something']],
            description="Post /offers")
        # /tmp/tmpxcCX8v_funkload/watch0034.request
        self.get(server_url+"/dashboard",
            description="Get /dashboard")
        # /tmp/tmpxcCX8v_funkload/watch0035.request
        self.get(server_url+"/offers/666",
            description="Get random offer")
        # /tmp/tmpxcCX8v_funkload/watch0036.request
        self.post(server_url+"/offers/666/accept/666", params=[
            ['utf8', '\xe2\x9c\x93'],
            ],
            description="Accept a bid")
        # /tmp/tmpxcCX8v_funkload/watch0036.request
        self.post(server_url+"/offers/666/complete/666", params=[
            ['utf8', '\xe2\x9c\x93'],
            ],
            description="Complete a bid")
        self.get(server_url+"/logout",
            description="Logout")

        # end of test -----------------------------------------------

    def tearDown(self):
        """Setting up test."""
        self.logd("tearDown.\n")



if __name__ in ('main', '__main__'):
    unittest.main()
