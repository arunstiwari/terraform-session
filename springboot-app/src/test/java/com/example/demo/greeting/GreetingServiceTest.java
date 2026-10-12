package com.example.demo.greeting;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class GreetingServiceTest {

	private final GreetingService service = new GreetingService();

	@Test
	void greetsByName() {
		assertThat(service.greet("Arun")).isEqualTo("Hello, Arun!");
	}

	@Test
	void trimsWhitespace() {
		assertThat(service.greet("  Arun  ")).isEqualTo("Hello, Arun!");
	}

	@Test
	void fallsBackToWorldWhenNameMissing() {
		assertThat(service.greet(null)).isEqualTo("Hello, World!");
		assertThat(service.greet("  ")).isEqualTo("Hello, World!");
	}

}
