package com.example.demo.greeting;

import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GreetingController {

	private final GreetingService greetingService;

	public GreetingController(GreetingService greetingService) {
		this.greetingService = greetingService;
	}

	@GetMapping("/api/greeting")
	public Map<String, String> greeting(@RequestParam(required = false) String name) {
		return Map.of("message", greetingService.greet(name));
	}

}
