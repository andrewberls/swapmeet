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
        self.current_user = 0

    def pick_user(self):
        self.current_user = (self.current_user + 1) % 200
        return self.current_user + 1

    def test_critical_path(self):
        # The description should be set in the configuration file
        server_url = self.server_url
        # begin of test ---------------------------------------------

        first_user_id = self.pick_user()
        second_user_id = first_user_id + 1

        self.post(server_url+"/users/sign_in", params=[
            ['utf8', '\xe2\x9c\x93'],
            ['user[login]', 'user'+str(first_user_id)],
            ['user[password]', 'password'],
            ['user[remember_me]', '0'],
            ['commit', 'Log in']],
            description="Login as the seller")
        self.get(server_url+"/offers/new",
            description="Prepare a new trade")
        posted_offer_response = self.post(server_url+"/offers", params=[
            ['utf8', '\xe2\x9c\x93'],
            ['offer[title]', 'TestingOffer'],
            ['offer[description]', 'Just for testing'],
            ['offer[image]', Upload("")],
            ['offer[tag_list]', 'test'],
            ['commit', 'Create Offer']],
            description="Post a new trade")
        posted_offer_id = int(posted_offer_response.url.split('/')[2])
        self.get(server_url+"/logout",
            description="Logout 1")


        self.post(server_url+"/users/sign_in", params=[
            ['utf8', '\xe2\x9c\x93'],
            ['user[login]', 'user'+str(second_user_id)],
            ['user[password]', 'password'],
            ['user[remember_me]', '0'],
            ['commit', 'Log in']],
            description="Login as the buyer")
        self.get(server_url+"/offers",
            description="Browse trades")
        self.get(server_url+"/offers/"+str(posted_offer_id),
            description="Look at an offer")
        self.get(server_url+"/offers/"+str(posted_offer_id)+"/bid",
            description="Load the new bid page")
        bid_response = self.post(server_url+"/offers/"+str(posted_offer_id)+"/bid", params=[
            ['utf8', '\xe2\x9c\x93'],
            ['offer[title]', 'TestingBid'],
            ['offer[description]', 'Just for testing'],
            ['offer[image]', Upload("")],
            ['offer[tag_list]', 'test'],
            ['commit', 'Bid on something']],
            description="Bid")
        marker = 'BID_ID:'
        start_index = bid_response.body.index(marker) + len(marker)
        bid_id=int(bid_response.body[start_index:start_index+20].split()[0])

        self.get(server_url+"/logout",
            description="Logout 2")
        self.post(server_url+"/users/sign_in", params=[
            ['utf8', '\xe2\x9c\x93'],
            ['user[login]', 'user'+str(first_user_id)],
            ['user[password]', 'password'],
            ['user[remember_me]', '0'],
            ['commit', 'Log in']],
            description="Login as the seller again")
        self.get(server_url+"/dashboard",
            description="Get /dashboard")
        self.get(server_url+"/offers/"+str(posted_offer_id),
            description="Look at the offer again")
        self.post(server_url+"/offers/"+str(posted_offer_id)+"/accept/"+str(bid_id), params=[
            ['utf8', '\xe2\x9c\x93'],
            ],
            description="Accept a bid")
        self.post(server_url+"/offers/"+str(posted_offer_id)+"/complete/"+str(bid_id), params=[
            ['utf8', '\xe2\x9c\x93'],
            ],
            description="Complete a bid")
        self.get(server_url+"/logout",
            description="Logout 3")

        # end of test -----------------------------------------------

    def tearDown(self):
        """Setting up test."""
        self.logd("tearDown.\n")



if __name__ in ('main', '__main__'):
    unittest.main()
