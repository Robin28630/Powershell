<?php
// src/Controller/AdvertController.php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

class AdvertController extends AbstractController
{
 public function index()
  {
    return $this->render('Advert/index.html.twig');

  }
 public function Sign_in()
 {
    return $this->render('Advert/Sign_in.html.twig');
 }

}