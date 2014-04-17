#ifndef  __ESNP_CODER_H__
#define  __ESNP_CODER_H__

#include <stdint.h>
#include <string>
#include "cocoa\CCValue.h"
#include "Buffer.h"

#define VVT_NULL		0
#define VVT_BOOLEAN		1
#define VVT_INT			2
#define VVT_INT8		3
#define VVT_INT16		4
#define VVT_INT32		5
#define VVT_INT64		6
#define VVT_UINT		7
#define VVT_UINT8		8
#define VVT_UINT16		9
#define VVT_UINT32		10
#define VVT_UINT64		11
#define VVT_FLOAT32		13
#define VVT_FLOAT64		14
// #define VVT_LEN_BYTES	17
#define VVT_MAP			21
#define VVT_LIST		23
#define VVT_LEN_STRING	24
#define VVT_STRING		24

USING_NS_CC;

class ESNPCoder
{
public:
	static bool readBool(ESNPBuffer* buf, int* err);
	static int writeBool(ESNPBuffer* buf, bool v);

	static int8_t readFixInt8(ESNPBuffer *buf, int* err);
	static int writeFixInt8(ESNPBuffer *buf, int8_t v);

	static int16_t readFixInt16(ESNPBuffer *buf, int* err);
	static int writeFixInt16(ESNPBuffer *buf, int16_t v);

	static int32_t readFixInt32(ESNPBuffer *buf, int* err);
	static int writeFixInt32(ESNPBuffer *buf, int32_t v);

	static int64_t readFixInt64(ESNPBuffer *buf, int* err);
	static int writeFixInt64(ESNPBuffer *buf, int64_t v);

	static uint8_t readFixUint8(ESNPBuffer *buf, int* err) {
		return (uint8_t) readFixInt8(buf, err);
	}
	static int writeFixUint8(ESNPBuffer *buf, uint8_t v) {
		return writeFixInt8(buf, (int8_t) v);
	}

	static uint16_t readFixUint16(ESNPBuffer *buf, int* err) {
		return (uint16_t) readFixInt16(buf, err);
	}
	static int writeFixUint16(ESNPBuffer *buf, uint16_t v) {
		return writeFixInt16(buf, (int16_t) v);
	}
	static uint32_t readFixUint32(ESNPBuffer *buf, int* err) {
		return (uint32_t) readFixInt32(buf, err);
	}
	static int writeFixUint32(ESNPBuffer *buf, uint32_t v) {
		return writeFixInt32(buf, (int32_t) v);
	}
	static uint64_t readFixUint64(ESNPBuffer *buf, int* err) {
		return (uint64_t) readFixInt64(buf, err);
	}
	static int writeFixUint64(ESNPBuffer *buf, uint64_t v) {
		return writeFixInt64(buf, (int64_t) v);
	}

	static float readFloat32(ESNPBuffer* buf, int* err);
	static int writeFloat32(ESNPBuffer* buf, float v);

	static double readFloat64(ESNPBuffer* buf, int* err);
	static int writeFloat64(ESNPBuffer* buf, double v);

	static uint16_t readUint16(ESNPBuffer *buf, int* err);
	static int writeUint16(ESNPBuffer *buf, uint16_t v);

	static uint32_t readUint32(ESNPBuffer *buf, int* err);
	static int writeUint32(ESNPBuffer *buf, uint32_t v);

	static uint64_t readUint64(ESNPBuffer *buf, int* err);
	static int writeUint64(ESNPBuffer *buf, uint64_t v);

	static int16_t readInt16(ESNPBuffer *buf, int* err);
	static int writeInt16(ESNPBuffer *buf, int16_t v);

	static int32_t readInt32(ESNPBuffer *buf, int* err);
	static int writeInt32(ESNPBuffer *buf, int32_t v);

	static int64_t readInt64(ESNPBuffer *buf, int* err);
	static int writeInt64(ESNPBuffer *buf, int64_t v);

	static std::string readString(ESNPBuffer *buf, int* err);	
	static int writeString(ESNPBuffer* buf, std::string v);

	static std::string readStringL(ESNPBuffer *buf, int len, int* err);
	static std::string readLenString(ESNPBuffer *buf, int* err);
	static int writeLenString(ESNPBuffer* buf, std::string v);

	static bool readVar(ESNPBuffer *buf, CCValueBuilder* builder, int* err);
	static int writeVar(ESNPBuffer* buf, CCValue& v);

	static void header(char* buf, int mt, int sz);
	static bool header(ESNPBuffer* buf, int* mt, int* sz);
};

#define MT_END					0x00
#define MT_MESSAGE_ID			0x11
#define MT_SOURCE_MESSAGE_ID	0x12
#define MT_HEADER				0x14
#define MT_DATA					0x15
#define MT_PAYLOAD				0x16
#define MT_ADDRESS				0x17
#define MT_ERROR				0x1D
#define MT_FLAG					0x1E

#define ADDRESS_SERVICE			30
#define ADDRESS_OP				20

#define FLAG_TRACE		1
#define FLAG_RESP		3
#define FLAG_REQUEST 	4
#define FLAG_INFO		5
#define FLAG_EVENT 		6

#endif