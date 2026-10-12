package com.example.demo.greeting;

import org.springframework.stereotype.Service;

@Service
public class GreetingService {

	public String greet(String name) {
		if (name == null || name.isBlank()) {
			return "Hello, World!";
		}
		return "Hello, " + name.trim() + "!";
	}

}
