import React from "react";
import PropTypes from "prop-types";
import PuncButton from "./PuncButton";
import ClauseSpan from "./ClauseSpan";

class Paragraph extends React.Component {
  constructor (props) {
    super(props);
  }
  
  choose (text, idx) {
    const punct = [
      '.',
      ',',
      '!',
      '?',
      ';',
      ':',
      '(',
      ')',
      '&ndash;',
      '&mdash;',
      '&hellip;',
    ];

    if (punct.indexOf(text) >= 0) {
      return(<PuncButton key={idx} punc={text} />);
    } else {
      return(<ClauseSpan clause={text} key={idx} />);
    }
  }
  
  paragraphParts (self, contentArray) {
    const components = [];

    contentArray.map(function (c, idx) {
      components.push(self.choose(c, idx));
    });
    return components;
  }
  
  render () {
    const array = JSON.parse(this.props.content.__html);
    const para = this.paragraphParts(this, array);
    return (
      <React.Fragment>
        <div className="msg-paragraph">
          <p
            className="msg-par-text"
          >
            { para }
          </p>
          <p className="msg-par-avatar">
            <a href='/'>
              <img draggable="false" src={ this.props.avatar } />
            </a>
            <br />
            <span className="id-time">{ this.props.who }</span>
            <br />
            <span
              className="id-time"
              title={ this.props.ts }
            >
              { this.props.when } ago
            </span>
          </p>
        </div>
      </React.Fragment>
    );
  }
}

Paragraph.propTypes = {
  avatar: PropTypes.string,
  text: PropTypes.string,
  ts: PropTypes.string,
  when: PropTypes.string,
  who: PropTypes.string,
};
export default Paragraph
