#pragma once

#include <stdint.h>
#include <string>

class Buffer
{
public:
	static Buffer* Create(int len, int glen) {
		Buffer* r = new Buffer();
		r->Init(len, glen);
		return r;
	}
	void Init(int len, int glen);
	static Buffer* Create(Buffer* ptr, int pos) {
		Buffer* r = new Buffer();
		r->Init(ptr, pos);
		return r;
	}
	void Init(Buffer* ptr, int pos);	

	int Write(char v);
	int WriteBytes(const char* buf, int c);
	int Read();
	int ReadBytes(char* buf, int c);
	int Remain();

	void Clear();
	std::string Dump();

public:
	Buffer(void);
	~Buffer(void);

protected:
	uint8_t* buffer;
	int pos, dlen, len, glen;
	int own;
};

